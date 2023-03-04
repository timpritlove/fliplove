defmodule Fluepdot do
  @moduledoc """
  Functions supporting the fluepdot hardware controller for flipdot displays by fluepke

  """
  alias Flipdot.DisplayState
  @host 'flipdot.local'
  @port 1337

  def send(bitmap) do
    send_bitmap_via_udp(bitmap)
  end

  def send_bitmap_via_udp(bitmap) do
    if bitmap.meta.width != DisplayState.width(), do: raise("Bitmap has the wrong width")
    if bitmap.meta.height != DisplayState.height(), do: raise("Bitmap has the wrong height")

    frame = Bitmap.to_binary(bitmap)

    spawn(__MODULE__, :do_resolve_and_send, [@host, @port, frame])
    bitmap
  end

  def do_resolve_and_send(host, port, frame) do
    {:ok, v4_addresses} = :inet.getaddrs(host, :inet)
    # {:ok, _v6_address} = :inet.getaddrs(@host), :inet6)

    {:ok, socket} = :gen_udp.open(0)
    :gen_udp.send(socket, List.first(v4_addresses), port, frame)
  end
end
