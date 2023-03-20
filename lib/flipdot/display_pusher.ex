defmodule Flipdot.DisplayPusher do
  alias Flipdot.DisplayPusher

  use GenServer
  require HTTPoison

  @host_env "FLIPDOT_HOST"
  @host_default "localhost"
  @port_env "FLIPDOT_PORT"
  @port_default 1337
  @rendering_mode_url "/rendering/mode"

  defstruct host: nil, port: nil, socket: nil, addresses: [], timer: nil

  def start_link(_config) do
    host =
      case System.get_env(@host_env) do
        nil -> @host_default
        host -> host
      end

    port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    GenServer.start_link(__MODULE__, %DisplayPusher{host: host, port: port}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, v4_addresses} = :inet.getaddrs(String.to_charlist(state.host), :inet)
    {:ok, socket} = :gen_udp.open(0)

    {:ok, timer} = :timer.send_interval(10_000, self(), :set_rendering_mode)

    Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.DisplayState.topic())
    {:ok, %{state | socket: socket, addresses: v4_addresses, timer: timer}}
  end

  @impl true
  def handle_info(:set_rendering_mode, state) do
    if state.host != "localhost" do
      {:ok, _response} = HTTPoison.put("http://" <> state.host <> @rendering_mode_url, <<1>>)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:display_update, bitmap}, state) do
    :gen_udp.send(
      state.socket,
      state.addresses |> List.first(),
      state.port,
      Bitmap.to_binary(bitmap)
    )

    {:noreply, state}
  end
end
