# TODO
# - change state to struct

defmodule Flipdot.DisplayState do
  require Flipdot.Bitmap, as: Bitmap

  defstruct bitmap: nil
  use Agent

  @topic "display_update"

  def start_link(bitmap) do
    bitmap = if bitmap == nil, do: Bitmap.new(width(), height()), else: bitmap

    Agent.start_link(fn -> %__MODULE__{bitmap: bitmap} end, name: __MODULE__)
  end

  def topic, do: @topic

  def width, do: Application.fetch_env!(:flipdot, :display)[:width]
  def height, do: Application.fetch_env!(:flipdot, :display)[:height]

  def get do
    Agent.get(__MODULE__, fn state -> state.bitmap end)
  end

  def clear do
    Bitmap.new(width(), height()) |> set()
  end

  def set(bitmap) do
    old_bitmap = get()

    if bitmap != old_bitmap do
      Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:display_update, bitmap})
      Agent.update(__MODULE__, fn _ -> %__MODULE__{bitmap: bitmap} end)
    end

    bitmap
  end
end
