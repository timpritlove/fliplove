defmodule Flipdot.Display do
  alias Flipdot.Bitmap
  alias Flipdot.Fluepdot

  @moduledoc """
  Store the current frame buffer of the virtual Bitmap Display. Send PubSub broadcasts
  whenever the content changes.
  """

  defstruct bitmap: nil
  use Agent

  @topic "display"

  def start_link(_) do
    # Always initialize with a blank bitmap
    initial_bitmap = Bitmap.new(width(), height())
    Agent.start_link(fn -> %__MODULE__{bitmap: initial_bitmap} end, name: __MODULE__)
  end

  def topic, do: @topic

  def width, do: Fluepdot.width()
  def height, do: Fluepdot.height()

  def get do
    case Agent.get(__MODULE__, fn state -> state.bitmap end) do
      nil ->
        # This should never happen, but just in case
        bitmap = Bitmap.new(width(), height())
        set(bitmap)
        bitmap
      bitmap -> bitmap
    end
  end

  def clear do
    Bitmap.new(width(), height()) |> set()
  end

  def set(bitmap) do
    old_bitmap = get()
    new_bitmap = Bitmap.crop_relative(bitmap, width(), height(), rel_x: :center, rel_y: :middle)

    if new_bitmap != old_bitmap do
      # Count pixels in the new bitmap
      pixel_count = count_active_pixels(new_bitmap)

      # Calculate normalized value (0-999)
      max_pixels = width() * height()
      normalized_value = trunc(pixel_count / max_pixels * 999)

      # Update Megabitmeter
      Flipdot.Megabitmeter.set_level(normalized_value)

      Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:display_updated, new_bitmap})
      Agent.update(__MODULE__, fn _ -> %__MODULE__{bitmap: new_bitmap} end)
    end

    bitmap
  end

  # Count active (1) pixels in the bitmap
  defp count_active_pixels(bitmap) do
    bitmap.matrix
    |> Map.values()
    |> Enum.count(&(&1 == 1))
  end
end
