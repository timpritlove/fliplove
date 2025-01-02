defmodule Fliplove.Display do
  alias Fliplove.Bitmap
  alias Fliplove.Driver

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

  def width, do: Driver.width()
  def height, do: Driver.height()

  def get do
    case Agent.get(__MODULE__, fn state -> state.bitmap end) do
      nil ->
        # This should never happen, but just in case
        bitmap = Bitmap.new(width(), height())
        set(bitmap)
        bitmap

      bitmap ->
        bitmap
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

      # Calculate normalized value (0.0 - 1.0)
      normalized_value = pixel_count / (width() * height())

      # Update megabitmeter
      Fliplove.Megabitmeter.set_level(normalized_value)

      # Store new bitmap
      Agent.update(__MODULE__, fn state -> %{state | bitmap: new_bitmap} end)

      # Broadcast update
      Phoenix.PubSub.broadcast(Fliplove.PubSub, @topic, {:display_updated, new_bitmap})
    end

    :ok
  end

  defp count_active_pixels(bitmap) do
    bitmap.matrix
    |> Map.values()
    |> Enum.count(&(&1 == 1))
  end
end
