defmodule Flipdot.Fluepdot.USB do
  @doc """
  Driver for Fluepdot Display via USB
  """
  use GenServer
  require Logger

  @device_env "FLIPDOT_DEVICE"
  @device_bitrate 115_200

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
        {:ok, uart_pid} = Circuits.UART.start_link()

        case Circuits.UART.open(uart_pid, device,
               speed: @device_bitrate,
               active: false
             ) do
          :ok ->
            Logger.info("Successfully opened serial connection to #{device}")

            # Initialize rendering mode
            case Circuits.UART.write(uart_pid, "config_rendering_mode differential\n") do
              :ok ->
                Logger.info("Successfully set USB rendering mode")
                {:ok, %{state | counter: 0, device: device, uart: uart_pid}}

              {:error, reason} ->
                Logger.error("Failed to set USB rendering mode: #{inspect(reason)}")
                {:stop, reason}
            end

          {:error, reason} ->
            Logger.error("Failed to open serial connection: #{inspect(reason)}")
            {:stop, reason}
        end
    end
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64()) <> "\n"

    case Circuits.UART.write(state.uart, cmd) do
      :ok ->
        counter = state.counter + 1
        Logger.debug("USB: Display updated (##{counter}).")
        {:noreply, %{state | counter: counter}}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.uart do
      Circuits.UART.close(state.uart)
    end
  end
end
