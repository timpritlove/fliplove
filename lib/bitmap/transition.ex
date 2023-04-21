defmodule Bitmap.Transition do
  # TODO:
  # * slide transitions in all directions
  # * push transitions in all directions

  def push_up(bitmap_a, bitmap_b) do
    {width, height} = Bitmap.dimensions(bitmap_a)

    if {width, height} != Bitmap.dimensions(bitmap_b) do
      raise("Bitmaps must have identical dimensions")
    end

    Stream.resource(
      fn ->
        bitmap_ab =
          Bitmap.new(width, height * 2)
          |> Bitmap.overlay(bitmap_a, cursor_x: 0, cursor_y: height)
          |> Bitmap.overlay(bitmap_b, cursor_x: 0, cursor_y: 0)

        {bitmap_ab, height}
      end,
      fn {bitmap_ab, row} ->
        cond do
          row < 0 ->
            {:halt, nil}

          true ->
            bitmap = Bitmap.crop(bitmap_ab, {0, row}, width, height)
            {[bitmap], {bitmap_ab, row - 1}}
        end
      end,
      fn _ -> nil end
    )
  end

  def push_down(bitmap_a, bitmap_b) do
    {width, height} = Bitmap.dimensions(bitmap_a)

    if {width, height} != Bitmap.dimensions(bitmap_b) do
      raise("Bitmaps must have identical dimensions")
    end

    Stream.resource(
      fn ->
        bitmap_ab =
          Bitmap.new(width, height * 2)
          |> Bitmap.overlay(bitmap_a, cursor_x: 0, cursor_y: 0)
          |> Bitmap.overlay(bitmap_b, cursor_x: 0, cursor_y: height)

        {bitmap_ab, 0}
      end,
      fn {bitmap_ab, row} ->
        cond do
          row > height ->
            {:halt, nil}

          true ->
            bitmap = Bitmap.crop(bitmap_ab, {0, row}, width, height)
            {[bitmap], {bitmap_ab, row + 1}}
        end
      end,
      fn _ -> nil end
    )
  end
end
