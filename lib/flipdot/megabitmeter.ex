defmodule Flipdot.Megabitmeter do
  use GenServer
  require Logger

  @reconnect_interval 5_000 # 5 seconds
  @boot_delay 5_000 # 5 seconds wait for device to boot
  @baud_rate 9600

  defmodule State do
    defstruct [:uart_pid, :device, :pending_value, connected?: false, booting?: false]
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
    device = System.get_env("FLIPDOT_MEGABITMETER_DEVICE")

    if is_nil(device) do
      Logger.warning("FLIPDOT_MEGABITMETER_DEVICE not configured, Megabitmeter will be disabled")
      {:ok, %State{device: nil}}
    else
      state = %State{device: device}
      {:ok, state, {:continue, :connect}}
    end
  end

  @impl true
  def handle_continue(:connect, state) do
    case open_uart(state.device) do
      {:ok, uart_pid} ->
        Logger.info("Connected to Megabitmeter at #{state.device}, waiting for boot...")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %State{state | uart_pid: uart_pid, booting?: true}}

      {:error, reason} ->
        Logger.info("Failed to connect to Megabitmeter: #{inspect(reason)}")
        schedule_reconnect()
        {:noreply, %State{state | connected?: false}}
    end
  end

  @impl true
  def handle_cast({:set_level, value}, %State{connected?: true, booting?: false} = state) do
    Logger.debug("Setting Megabitmeter level to #{value}")
    write_value(state.uart_pid, value)
    {:noreply, state}
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
        Logger.info("Reconnected to Megabitmeter at #{state.device}, waiting for boot...")
        Process.send_after(self(), :boot_complete, @boot_delay)
        {:noreply, %State{state | uart_pid: uart_pid, booting?: true}}

      {:error, reason} ->
        Logger.debug("Failed to reconnect to Megabitmeter: #{inspect(reason)}")
        schedule_reconnect()
        {:noreply, state}
    end
  end

  def handle_info({:circuits_uart, device, {:error, :eio}}, %State{device: device} = state) do
    Logger.info("Megabitmeter disconnected from #{device}")
    Circuits.UART.close(state.uart_pid)
    schedule_reconnect()
    {:noreply, %State{state | uart_pid: nil, connected?: false, booting?: false}}
  end

  defp open_uart(device) do
    Logger.debug("Attempting to connect to Megabitmeter at #{device}")
    Circuits.UART.start_link()
    |> case do
      {:ok, uart_pid} ->
        case Circuits.UART.open(uart_pid, device, speed: @baud_rate, active: true) do
          :ok -> {:ok, uart_pid}
          error -> error
        end

      error ->
        error
    end
  end

  defp write_value(uart_pid, value) do
    message = "#{value}\n"
    Circuits.UART.write(uart_pid, message)
  end

  defp schedule_reconnect do
    Process.send_after(self(), :try_reconnect, @reconnect_interval)
  end
end 