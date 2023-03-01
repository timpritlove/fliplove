defmodule BitmapExp do
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

    %Bitmap{
      meta: %{width: range_x + 1, height: range_y + 1},
      matrix: normalised_matrix
    }
  end

  def overlay_alt(background, overlay, options \\ []) do
    # Allow cursor position in background and bounding box in bitmap
    # to be passed as parameters.
    # default to unshifted positions with all pixels included.

    options =
      Keyword.validate!(options,
        cursor_x: 0,
        cursor_y: 0,
        bb_width: overlay.meta.width,
        bb_height: overlay.meta.height,
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
          options[:infinite] or bg_x < background.meta.width,
          options[:infinite] or bg_y < background.meta.height,
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

    {width, height} =
      if options[:infinite] do
        Enum.reduce(
          Map.filter(overlay_matrix, fn {_, value} -> value == 1 end) |> Map.keys(),
          {background.meta.width, background.meta.height},
          fn {x, y}, {max_width, max_height} ->
            {max(x + 1, max_width), max(y + 1, max_height)}
          end
        )
      else
        {background.meta.width, background.meta.height}
      end

    %Bitmap{
      meta: %{background.meta | width: width, height: height},
      matrix: Map.merge(background.matrix, overlay_matrix)
    }
  end

  @doc """
  Generate a maze
  """

  def maze(width, height) do
    start_y = div(height, 2)

    Bitmap.new(width, height)
    |> Bitmap.invert()
    |> Bitmap.set_pixel(1, start_y, 0)
    |> maze_gen([{1, start_y}])
  end

  defp maze_gen(bitmap, []) do
    bitmap
  end

  defp maze_gen(bitmap, visited_cells) do
    IO.inspect(visited_cells, label: "stack")
    {cur_x, cur_y} = hd(visited_cells)

    unvisited_neighbors =
      for {x, y} <- [
            {cur_x, cur_y + 2},
            {cur_x + 2, cur_y},
            {cur_x, cur_y - 2},
            {cur_x - 2, cur_y}
          ],
          x >= 0,
          y >= 0,
          x < bitmap.meta.width,
          y < bitmap.meta.height,
          Bitmap.get_pixel(bitmap, x, y) == 1 do
        {x, y}
      end

    case unvisited_neighbors do
      [] ->
        maze_gen(bitmap, tl(visited_cells))

      list ->
        {next_x, next_y} = Enum.random(list)

        {wall_x, wall_y} =
          cond do
            cur_x == next_x -> {cur_x, min(cur_y, next_y) + 1}
            cur_y == next_y -> {min(cur_x, next_x) + 1, cur_y}
          end

        bitmap
        |> Bitmap.set_pixel(wall_x, wall_y, 0)
        |> Bitmap.set_pixel(next_x, next_y, 0)
        |> maze_gen([{next_x, next_y} | visited_cells])
    end
  end
end
