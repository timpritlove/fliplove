defmodule Flipdot.Megabitmeter do
  use GenServer
  require Logger

  @reconnect_interval 5_000 # 5 seconds
  @boot_delay 5_000 # 5 seconds wait for device to boot
  @baud_rate 9600
  @animation_steps 10
  @animation_interval 100 # 100ms between steps (2000ms total)
  @max_write_retries 3

  defmodule State do
    defstruct [
      :uart_pid,
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

  def set_level(value) when value >= 0 and value <= 999 do
    GenServer.cast(__MODULE__, {:set_level, value})
  end

  def set_level(_), do: {:error, :invalid_value}

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    device = System.get_env("FLIPDOT_MEGABITMETER_DEVICE")

    if is_nil(device) do
      Logger.warning("FLIPDOT_MEGABITMETER_DEVICE not configured, Megabitmeter will be disabled")
      {:ok, %State{device: nil, current_value: 0, target_value: 0, animation_timer: nil, step_size: nil}}
    else
      state = %State{
        device: device,
        current_value: 0,
        target_value: 0,
        animation_timer: nil,
        step_size: nil
      }
      {:ok, state, {:continue, :connect}}
    end
  end

  @impl true
  def handle_continue(:connect, state) do
    case open_uart(state.device) do
      {:ok, uart_pid} ->
        Logger.info("Connected to Megabitmeter at #{state.device}, waiting for boot...")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %State{state |
          uart_pid: uart_pid,
          booting?: true,
          current_value: state.current_value,
          target_value: state.target_value,
          animation_timer: state.animation_timer
        }}

      {:error, reason} ->
        Logger.info("Failed to connect to Megabitmeter: #{inspect(reason)}")
        schedule_reconnect()
        {:noreply, %State{state |
          connected?: false,
          current_value: state.current_value,
          target_value: state.target_value,
          animation_timer: state.animation_timer
        }}
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
    Logger.debug("Device not connected, storing level #{value} to set after connection")
    {:noreply, %State{state | pending_value: value}}
  end

  @impl true
  def handle_info(:boot_complete, state) do
    Logger.info("Megabitmeter boot complete at #{state.device}")
    new_state = %State{state | connected?: true, booting?: false}

    # Set any pending value that was stored during boot
    case new_state.pending_value do
      nil -> :ok
      value ->
        Logger.debug("Setting pending value #{value} after boot")
        write_value(state.uart_pid, value)
    end

    {:noreply, %State{new_state | pending_value: nil}}
  end

  def handle_info(:try_reconnect, state) do
    case open_uart(state.device) do
      {:ok, uart_pid} ->
        Logger.info("Connected to Megabitmeter at #{state.device}")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %State{state | uart_pid: uart_pid, booting?: true}}

      {:error, _reason} ->
        schedule_reconnect()
        {:noreply, state}
    end
  end

  def handle_info({:circuits_uart, device, {:error, reason}}, %State{device: device} = state) do
    Logger.debug("Megabitmeter error on #{device}: #{inspect(reason)}")

    # Only log disconnection if we were previously connected
    if state.connected? do
      Logger.info("Megabitmeter disconnected")
    end

    # Clean up the existing connection
    if state.uart_pid do
      Circuits.UART.close(state.uart_pid)
    end

    # Reset state and schedule reconnect
    schedule_reconnect()
    {:noreply, %State{state |
      uart_pid: nil,
      connected?: false,
      booting?: false,
      animation_timer: nil  # Cancel any ongoing animation
    }}
  end

  def handle_info({:circuits_uart, _port, msg}, state) do
    Logger.debug("Unexpected UART message: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, reason}, %State{uart_pid: uart_pid} = state) when pid == uart_pid do
    Logger.debug("UART process crashed: #{inspect(reason)}")
    schedule_reconnect()
    {:noreply, %State{state | uart_pid: nil, connected?: false, booting?: false}}
  end

  def handle_info(:animate_step, %State{current_value: current, target_value: target, step_size: step_size} = state) do
    if current == target do
      {:noreply, %State{state | animation_timer: nil, step_size: nil}}
    else
      next_value = round(current + step_size)
      next_value = if step_size > 0,
        do: min(next_value, target),
        else: max(next_value, target)

      case write_value(state.uart_pid, next_value) do
        :ok ->
          timer = if next_value != target do
            Process.send_after(self(), :animate_step, @animation_interval)
          end

          {:noreply, %State{state |
            current_value: next_value,
            animation_timer: timer
          }}

        {:error, _reason} ->
          # Keep current state, reconnection will be triggered by handle_write_error
          {:noreply, state}
      end
    end
  end

  defp open_uart(device) do
    Logger.debug("Attempting to connect to Megabitmeter at #{device}")
    try do
      with {:ok, uart_pid} <- Circuits.UART.start_link(),
           :ok <- Circuits.UART.open(uart_pid, device, speed: @baud_rate, active: true) do
        {:ok, uart_pid}
      else
        {:error, reason} = error ->
          Logger.debug("Failed to open UART: #{inspect(reason)}")
          error
      end
    catch
      :exit, {:timeout, _} ->
        Logger.debug("Timeout while opening UART connection")
        {:error, :timeout}
    end
  end

  defp write_value(uart_pid, value, retry_count \\ 0) do
    message = "#{value}\n"
    try do
      case Circuits.UART.write(uart_pid, message) do
        :ok -> :ok
        {:error, reason} ->
          handle_write_error(uart_pid, value, reason, retry_count)
      end
    catch
      :exit, {:timeout, _} ->
        handle_write_error(uart_pid, value, :timeout, retry_count)
    end
  end

  defp handle_write_error(uart_pid, value, reason, retry_count) when retry_count < @max_write_retries do
    Logger.warning("Megabitmeter write failed (attempt #{retry_count + 1}): #{inspect(reason)}")
    Process.sleep(100) # Brief pause before retry
    write_value(uart_pid, value, retry_count + 1)
  end

  defp handle_write_error(uart_pid, _value, reason, _retry_count) do
    Logger.error("Megabitmeter write failed after retries: #{inspect(reason)}")
    # Force reconnection cycle
    send(self(), {:circuits_uart, uart_pid, {:error, :eio}})
    {:error, reason}
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
      %State{state |
        current_value: current,
        target_value: target_value,
        step_size: step_size,
        animation_timer: timer
      }
    else
      state
    end
  end
end
