defmodule Flipdot.Fluepdot.USB do
  alias Flipdot.Bitmap

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
            state = %{state | device: device, uart: uart_pid, counter: 0}

            with :ok <- write_command(state, "config_rendering_mode differential"),
                 :ok <- write_command(state, "flipdot_clear") do
              Logger.info("Successfully initialized USB display")
              {:ok, state}
            else
              {:error, reason} ->
                Logger.error("Failed to initialize USB display: #{inspect(reason)}")
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
    cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64())

    case write_command(state, cmd) do
      :ok ->
        counter = state.counter + 1
        Logger.debug("USB: Display updated (##{counter}).")
        {:noreply, %{state | counter: counter}}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        {:noreply, state}
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
