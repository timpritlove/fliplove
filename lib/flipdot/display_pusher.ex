defmodule Flipdot.DisplayPusher do
  alias Flipdot.DisplayPusher
  alias Flipdot.Bitmap
  use GenServer

  @host_env "FLIPDOT_HOST"
  @host_default 'localhost'
  @port_env "FLIPDOT_PORT"
  @port_default 1337

  # @req_rendering_mode '/rendering/mode'
  defstruct host: nil, port: nil, socket: nil, addresses: []

  def start_link(_config) do
    host =
      case System.get_env(@host_env) do
        nil -> @host_default
        host -> String.to_charlist(host)
      end

    port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    state = %DisplayPusher{host: host, port: port}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    IO.inspect(state.host, label: "host")
    {:ok, v4_addresses} = :inet.getaddrs(state.host, :inet)
    {:ok, socket} = :gen_udp.open(0)

    state = %{state | socket: socket, addresses: v4_addresses}

    Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.DisplayState.topic())
    {:ok, state}
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
