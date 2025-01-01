defmodule Flipdot.Driver.FluepdotWifi do
  alias Flipdot.Bitmap

  @doc """
  Driver for Fluepdot Display via Network (UDP + HTTP)
  """
  use GenServer
  require HTTPoison
  require Logger

  @host_env "FLIPDOT_HOST"
  @port_env "FLIPDOT_PORT"
  @port_default 1337

  @rendering_mode_url "/rendering/mode"

  defstruct counter: 0, host: nil, port: nil, socket: nil, addresses: [], timer: nil, connected: false

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    host = System.get_env(@host_env)

    port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    {:ok, v4_addresses} = :inet.getaddrs(String.to_charlist(host), :inet)
    {:ok, socket} = :gen_udp.open(0)

    # Initialize rendering mode
    case HTTPoison.put(Path.join(["http://", host, @rendering_mode_url]), <<?1>>) do
      {:ok, %{status_code: 200}} ->
        Logger.info("Successfully set UDP rendering mode")

      {:ok, %{status_code: status_code}} ->
        Logger.warning("Failed to set UDP rendering mode. Status code: #{status_code}")

      {:error, reason} ->
        Logger.warning("Failed to set UDP rendering mode. Reason: #{inspect(reason)}")
    end

    {:ok, timer} = :timer.send_interval(10_000, self(), :check_connection)

    {:ok,
     %{
       state
       | host: host,
         port: port,
         socket: socket,
         addresses: v4_addresses,
         timer: timer,
         counter: 0
     }}
  end

  def handle_info({:display_updated, bitmap}, state) do
    :gen_udp.send(
      state.socket,
      state.addresses |> List.first(),
      state.port,
      Bitmap.to_binary(bitmap)
    )

    counter = state.counter + 1
    Logger.debug("UDP: Display updated (##{counter}).")
    {:noreply, %{state | counter: counter}}
  end

  @impl true
  def handle_info(:check_connection, state) do
    {:noreply, state}
  end

  # receive reply UDP packet
  def handle_info(_udp, state) do
    # IO.inspect(udp, label: "udp")
    Logger.debug("UDP: Received confirmation packet")
    {:noreply, state}
  end
end
