defmodule Bitmap.Transition do
  def push_up(bitmap_a, bitmap_b) do
    if Bitmap.dimensions(bitmap_a) != Bitmap.dimensions(bitmap_b) do
      raise("Bitmaps must have identical dimensions")
    end

    Stream.resource(
      fn ->
        bitmap_ab =
          Bitmap.new(bitmap_a.width, bitmap_a.height * 2)
          |> Bitmap.overlay(bitmap_a, cursor_x: 0, cursor_y: bitmap_a.height)
          |> Bitmap.overlay(bitmap_b, cursor_x: 0, cursor_y: 0)

        {bitmap_ab, bitmap_a.height, Bitmap.dimensions(bitmap_a)}
      end,
      fn {bitmap_ab, row, {width, height}} ->
        cond do
          row < 0 ->
            {:halt, nil}

          true ->
            bitmap = Bitmap.crop(bitmap_ab, {0, row}, width, height)
            {[bitmap], {bitmap_ab, row - 1, {width, height}}}
        end
      end,
      fn _ -> nil end
    )
  end
end
