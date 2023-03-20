defmodule BitmapExp do
  alias Flipdot.Bitmap

  @doc """
  Clip and normalise the bitmap
  - clip image to pixels within bounding box
  - adjust height and width properties accordingly
  - translate all coordinates to {0,0} reference point
  """
  def clip_and_normalise(bitmap) do
    {min_x, min_y, max_x, max_y} = Bitmap.bbox(bitmap)
    range_x = max_x - min_x
    range_y = max_y - min_y

    normalised_matrix =
      for x <- 0..range_x, y <- 0..range_y, into: %{} do
        {{x, y}, Map.get(bitmap.matrix, {min_x + x, min_y + y}, 0)}
      end

    Bitmap.new(range_x + 1, range_y + 1, normalised_matrix)
  end

  def overlay_alt(background, overlay, options \\ []) do
    # Allow cursor position in background and bounding box in bitmap
    # to be passed as parameters.
    # default to unshifted positions with all pixels included.

    options =
      Keyword.validate!(options,
        cursor_x: 0,
        cursor_y: 0,
        bb_width: Bitmap.width(overlay),
        bb_height: Bitmap.height(overlay),
        bb_x_off: 0,
        bb_y_off: 0,
        opaque: false,
        infinite: false
      )

    # create new overlay matrix

    overlay_matrix =
      for x <- 0..(options[:bb_width] - 1),
          y <- 0..(options[:bb_height] - 1),
          bg_x = options[:cursor_x] + options[:bb_x_off] + x,
          bg_y = options[:cursor_y] + options[:bb_y_off] + y,
          options[:infinite] or bg_x >= 0,
          options[:infinite] or bg_y >= 0,
          options[:infinite] or bg_x < Bitmap.width(background),
          options[:infinite] or bg_y < Bitmap.height(background),
          into: %{} do
        pixel = Map.get(overlay.matrix, {x, y}, 0)

        cond do
          pixel == 1 ->
            {{bg_x, bg_y}, 1}

          pixel == 0 and options[:opaque] ->
            {{bg_x, bg_y}, 0}

          pixel == 0 and not options[:opaque] ->
            {{bg_x, bg_y}, Map.get(background.matrix, {bg_x, bg_y}, 0)}
        end
      end

    {new_width, new_height} =
      if options[:infinite] do
        Enum.reduce(
          Map.filter(overlay_matrix, fn {_, value} -> value == 1 end) |> Map.keys(),
          {Bitmap.width(background), Bitmap.height(background)},
          fn {x, y}, {max_width, max_height} ->
            {max(x + 1, max_width), max(y + 1, max_height)}
          end
        )
      else
        {Bitmap.width(background), Bitmap.height(background)}
      end

    Bitmap.new(new_width, new_height, Map.merge(background.matrix, overlay_matrix))
  end
end
