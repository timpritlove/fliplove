defmodule Flipdot.Fluepdot.USB do
  @doc """
  Driver for Fluepdot Display via USB
  """
  use GenServer
  require Logger

  # usb mode
  @device_env "FLIPDOT_DEVICE"
  @device_bitrate 115_200

  defstruct [:counter, :device, :timer, connected: false]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    case System.get_env(@device_env) do
      nil ->
        {:stop, "#{@device_env} environment variable not set"}

      device ->
        # replace this with connection monitor
        case System.cmd("stty", ["-F", device, Integer.to_string(@device_bitrate)]) do
          {_result, 0} -> Logger.info("TTY settings for #{device} have been set")
          {result, status} -> Logger.warning("Can't set TTY settings: #{result} (#{status})")
        end

        {:ok, %{state | counter: 0, device: device}}
    end
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64()) <> "\n"

    case File.write(state.device, cmd, [:write, :raw]) do
      :ok -> {:noreply, state}
      {:error, reason} -> raise(reason)
    end

    counter = state.counter + 1
    # Logger.debug("USB: Display updated (##{counter}).")
    {:noreply, %{state | counter: counter}}
  end
end
