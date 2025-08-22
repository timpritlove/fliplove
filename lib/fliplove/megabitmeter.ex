defmodule Fliplove.Megabitmeter do
  @moduledoc """
  Driver for Megabitmeter flipdot display via serial connection.

  This GenServer manages communication with a Megabitmeter flipdot display
  over serial/UART connection. It handles device connection, bitmap transmission,
  and provides animated transitions for smooth visual updates.

  ## Features
  - Automatic serial device discovery and connection
  - Bitmap data transmission with retry logic
  - Smooth animated transitions between frames
  - Device reconnection on connection loss
  - Configurable baud rate and timing parameters

  ## Configuration
  - Baud rate: 9600
  - Boot delay: 5 seconds
  - Animation: 10 steps over 1000ms
  - Auto-reconnect on failure
  """
  use GenServer
  require Logger

  # 5 seconds
  @reconnect_interval 5_000
  # 5 seconds wait for device to boot
  @boot_delay 5_000
  @baud_rate 9600
  @animation_steps 10
  # 100ms between steps (2000ms total)
  @animation_interval 100
  @max_write_retries 3

  defmodule State do
    @moduledoc """
    Internal state structure for the Megabitmeter driver GenServer.

    Tracks UART connection, device information, and animation state.
    """
    defstruct [
      # The UART process
      :uart,
      # Device path
      :device,
      :pending_value,
      :current_value,
      :target_value,
      :animation_timer,
      :step_size,
      connected?: false,
      booting?: false
    ]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set_level(value, max_value) when is_number(value) and is_number(max_value) and max_value > 0 do
    # Normalize value to 0-999 range
    normalized_value = round(value / max_value * 999)
    # Clamp to valid range
    level = max(0, min(normalized_value, 999))
    GenServer.cast(__MODULE__, {:set_level, level})
  end

  def set_level(_value, _max_value), do: {:error, :invalid_value}

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    device = System.get_env("FLIPLOVE_MEGABITMETER_DEVICE")

    if is_nil(device) do
      Logger.warning("FLIPLOVE_MEGABITMETER_DEVICE not configured, Megabitmeter will be disabled")
      {:ok, %State{device: nil, current_value: 0, target_value: 0, animation_timer: nil, step_size: nil}}
    else
      # Start the UART process
      case Circuits.UART.start_link() do
        {:ok, uart} ->
          state = %State{
            uart: uart,
            device: device,
            current_value: 0,
            target_value: 0,
            animation_timer: nil,
            step_size: nil
          }

          {:ok, state, {:continue, :connect}}

        {:error, reason} ->
          Logger.error("Failed to start UART process: #{inspect(reason)}")
          {:stop, reason}
      end
    end
  end

  @impl true
  def handle_continue(:connect, state) do
    case try_connect(state) do
      {:ok, new_state} ->
        Logger.info("Connected to Megabitmeter at #{state.device}, waiting for boot...")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %{new_state | booting?: true}}

      {:error, reason} ->
        Logger.info("Failed to connect to Megabitmeter: #{inspect(reason)}")
        schedule_reconnect()
        {:noreply, %{state | connected?: false}}
    end
  end

  @impl true
  def handle_cast({:set_level, value}, %State{connected?: true, booting?: false} = state) do
    Logger.debug("Setting Megabitmeter level to #{value}")

    # Cancel any existing animation
    if state.animation_timer, do: Process.cancel_timer(state.animation_timer)

    # Start new animation
    new_state = start_animation(state, value)
    {:noreply, new_state}
  end

  def handle_cast({:set_level, value}, %State{connected?: true, booting?: true} = state) do
    Logger.debug("Device booting, storing level #{value} to set after boot")
    {:noreply, %State{state | pending_value: value}}
  end

  def handle_cast({:set_level, value}, state) do
    # Device not ready, store value silently
    {:noreply, %State{state | pending_value: value}}
  end

  @impl true
  def handle_info(:boot_complete, state) do
    Logger.info("Megabitmeter boot complete at #{state.device}")
    new_state = %State{state | connected?: true, booting?: false}

    # Set any pending value that was stored during boot
    case new_state.pending_value do
      nil ->
        :ok

      value ->
        Logger.debug("Setting pending value #{value} after boot")
        write_value(state, value)
    end

    {:noreply, %State{new_state | pending_value: nil}}
  end

  def handle_info(:try_reconnect, state) do
    case try_connect(state) do
      {:ok, new_state} ->
        Logger.info("Connected to Megabitmeter at #{state.device}")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %{new_state | booting?: true}}

      {:error, _reason} ->
        schedule_reconnect()
        {:noreply, state}
    end
  end

  def handle_info({:circuits_uart, _port, {:error, reason}}, state) do
    Logger.debug("Megabitmeter error: #{inspect(reason)}")

    # Only log disconnection if we were previously connected
    if state.connected? do
      Logger.info("Megabitmeter disconnected")
    end

    # Close the port but keep the UART process
    Circuits.UART.close(state.uart)

    # Reset state and schedule reconnect
    schedule_reconnect()
    {:noreply, %State{state | connected?: false, booting?: false, animation_timer: nil}}
  end

  def handle_info({:circuits_uart, _port, msg}, state) do
    Logger.debug("Unexpected UART message: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_info(:animate_step, %State{connected?: false} = state) do
    # If we're disconnected, cancel the animation
    {:noreply, %State{state | animation_timer: nil, step_size: nil}}
  end

  def handle_info(:animate_step, %State{current_value: current, target_value: target, step_size: step_size} = state) do
    if current == target do
      {:noreply, %State{state | animation_timer: nil, step_size: nil}}
    else
      next_value = round(current + step_size)

      next_value =
        if step_size > 0,
          do: min(next_value, target),
          else: max(next_value, target)

      case write_value(state, next_value) do
        :ok ->
          timer =
            if next_value != target do
              Process.send_after(self(), :animate_step, @animation_interval)
            end

          {:noreply, %State{state | current_value: next_value, animation_timer: timer}}

        {:error, _reason} ->
          # Animation will be cancelled by the disconnect handler
          {:noreply, state}
      end
    end
  end

  # Attempt to connect to the device using the existing UART process
  defp try_connect(%{uart: uart, device: device} = state) do
    case Circuits.UART.open(uart, device, speed: @baud_rate, active: true) do
      :ok -> {:ok, %{state | connected?: true}}
      error -> error
    end
  end

  # Write a value to the device with retries
  defp write_value(state, value, retry_count \\ 0)

  defp write_value(_state, _value, retry_count) when retry_count >= @max_write_retries do
    {:error, :max_retries}
  end

  defp write_value(%{uart: uart} = state, value, retry_count) do
    message = "#{value}\n"

    case Circuits.UART.write(uart, message) do
      :ok ->
        :ok

      {:error, :ebadf} ->
        # Port is closed, trigger reconnect
        send(self(), {:circuits_uart, uart, {:error, :ebadf}})
        {:error, :not_connected}

      {:error, _reason} when retry_count < @max_write_retries ->
        Process.sleep(100)
        write_value(state, value, retry_count + 1)

      error ->
        error
    end
  end

  defp schedule_reconnect do
    Process.send_after(self(), :try_reconnect, @reconnect_interval)
  end

  defp start_animation(state, target_value) do
    # If no current value is set, initialize to 0
    current = state.current_value || 0

    if current != target_value do
      # Calculate the fixed step size once
      step_size = (target_value - current) / @animation_steps

      # Start the animation
      timer = Process.send_after(self(), :animate_step, @animation_interval)
      %State{state | current_value: current, target_value: target_value, step_size: step_size, animation_timer: timer}
    else
      state
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.uart do
      Circuits.UART.close(state.uart)
    end
  end
end
