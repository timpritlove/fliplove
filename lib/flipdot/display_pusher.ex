defmodule Flipdot.DisplayPusher do
  alias Flipdot.DisplayPusher
  use GenServer

  defstruct host: 'localhost', port: 1337, socket: nil, addresses: []

def start_link(_config) do
  state = %DisplayPusher{}

  GenServer.start_link(__MODULE__, state, name: __MODULE__)
end

@impl true
def init(state) do
  {:ok, v4_addresses} = :inet.getaddrs(state.host, :inet)
  {:ok, socket} = :gen_udp.open(0)

  state = %{state | socket: socket, addresses: v4_addresses}

  Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.DisplayState.topic())
  {:ok, state}
end

@impl true
def handle_info({:display_update, bitmap}, state) do
  :gen_udp.send(state.socket, state.addresses |> List.first, state.port, Bitmap.to_binary(bitmap))
  {:noreply, state}
end
end
