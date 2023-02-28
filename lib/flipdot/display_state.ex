# TODO
# - change state to struct

defmodule Flipdot.DisplayState do
  defstruct bitmap: nil
  use Agent

  @topic "display_update"

  def start_link(bitmap) do
    Agent.start_link(fn -> %__MODULE__{bitmap: bitmap} end, name: __MODULE__)
  end

  def topic, do: @topic

  def get do
    Agent.get(__MODULE__, fn state -> state.bitmap end)
  end

  def set(bitmap) do
    old_bitmap = get()

    if bitmap != old_bitmap do
      Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:display_update, bitmap})
      Agent.update(__MODULE__, fn _ -> %__MODULE__{bitmap: bitmap} end)
    end
  end
end
