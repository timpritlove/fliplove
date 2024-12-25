defmodule Flipdot.Fluepdot.USB do
  alias Flipdot.Bitmap

  @doc """
  Driver for Fluepdot Display via USB
  """
  use GenServer
  require Logger

  @device_env "FLIPDOT_DEVICE"
  @device_bitrate 115_200
  @retry_interval 5000  # 5 seconds between retries

  defstruct [:counter, :device, :uart, :timer, connected: false]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    case System.get_env(@device_env) do
      nil ->
        {:stop, "#{@device_env} environment variable not set"}

      device ->
        send(self(), :try_connect)
        {:ok, %{state | device: device}}
    end
  end

  @impl true
  def handle_info(:try_connect, state) do
    case initialize_connection(state) do
      {:ok, new_state} ->
        Logger.info("Successfully initialized USB display")
        {:noreply, new_state}

      {:error, reason} ->
        Logger.error("Failed to initialize USB display: #{inspect(reason)}, retrying in #{@retry_interval}ms")
        Process.send_after(self(), :try_connect, @retry_interval)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:display_updated, bitmap}, %{connected: true} = state) do
    cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64())

    case write_command(state, cmd) do
      :ok ->
        counter = state.counter + 1
        Logger.debug("USB: Display updated (##{counter}).")
        {:noreply, %{state | counter: counter}}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        # If we fail to write, try reconnecting
        send(self(), :try_connect)
        {:noreply, %{state | connected: false}}
    end
  end

  def handle_info({:display_updated, _bitmap}, state) do
    # If not connected, ignore display updates
    {:noreply, state}
  end

  # Helper function for initializing the connection
  defp initialize_connection(state) do
    with {:ok, uart_pid} <- Circuits.UART.start_link(),
         :ok <- Circuits.UART.open(uart_pid, state.device,
                speed: @device_bitrate,
                active: false
              ),
         _ <- Logger.info("Successfully opened serial connection to #{state.device}"),
         :ok <- write_command(%{state | uart: uart_pid}, "config_rendering_mode differential"),
         :ok <- write_command(%{state | uart: uart_pid}, "flipdot_clear") do
      {:ok, %{state | uart: uart_pid, counter: 0, connected: true}}
    else
      {:error, reason} = error ->
        if state.uart do
          Circuits.UART.close(state.uart)
        end
        Logger.error("Failed to initialize USB connection: #{inspect(reason)}")
        error
    end
  end

  # Helper function for writing commands
  defp write_command(state, command) do
    Circuits.UART.write(state.uart, command <> "\n")
  end

  @impl true
  def terminate(_reason, state) do
    if state.uart do
      Circuits.UART.close(state.uart)
    end
  end
end
