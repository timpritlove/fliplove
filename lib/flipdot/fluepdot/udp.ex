defmodule Flipdot.Fluepdot.UDP do
  @doc """
  Driver for Fluepdot Display via UDP
  """
  use GenServer
  require HTTPoison
  require Logger

  @host_env "FLIPDOT_HOST"
  @port_env "FLIPDOT_PORT"
  @port_default 1337

  @set_rendering_mode false
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
    # Logger.debug("UDP: Display updated (##{counter}).")
    {:noreply, %{state | counter: counter}}
  end

  @impl true
  def handle_info(:check_connection, state) do
    if @set_rendering_mode do
      case HTTPoison.put(Path.join(["http://", state.host, @rendering_mode_url]), <<?1>>) do
        {:ok, response} ->
          case response.status_code do
            200 ->
              true

            status_code ->
              Logger.debug("Call to set rendering mode returned status code #{status_code}")
          end

        {:error, reason} ->
          Logger.warning("Could not set rendering mode. Reason: #{inspect(reason)}")
      end
    end

    {:noreply, state}
  end

  # receive reply UDP packet
  def handle_info(_udp, state) do
    # IO.inspect(udp, label: "udp")
    Logger.debug("Received confirmation UDP packet")
    {:noreply, state}
  end
end
