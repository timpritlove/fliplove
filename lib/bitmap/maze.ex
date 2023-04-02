defmodule Bitmap.Maze do
  @doc """
  Generate a maze. Both width and height must be odd numbers
  """
  require Integer

  def generate_maze(width, height) do
    if Integer.is_even(width) or Integer.is_even(height),
      do: raise("maze dimensions must be odd numbers")

    {start_x, start_y} = {Enum.random(1..(width - 1)//2), Enum.random(1..(height - 1)//2)}

    {entry_x, entry_y} = {0, Enum.random(1..(height - 1)//2)}
    {exit_x, exit_y} = {width - 1, Enum.random(1..(height - 1)//2)}

    Bitmap.new(width, height)
    |> Bitmap.invert()
    |> Bitmap.set_pixel({start_x, start_y}, 0)
    |> do_generate_maze([{start_x, start_y}])
    |> Bitmap.set_pixel({entry_x, entry_y}, 0)
    |> Bitmap.set_pixel({exit_x, exit_y}, 0)
  end

  defp do_generate_maze(bitmap, []) do
    bitmap
  end

  defp do_generate_maze(bitmap, visited_cells) do
    {width, height} = Bitmap.dimensions(bitmap)

    {cur_x, cur_y} = hd(visited_cells)

    unvisited_neighbors =
      for {nx, ny, wx, wy, _} <- [
            {cur_x, cur_y + 2, cur_x, cur_y + 1, :up},
            {cur_x + 2, cur_y, cur_x + 1, cur_y, :right},
            {cur_x, cur_y - 2, cur_x, cur_y - 1, :down},
            {cur_x - 2, cur_y, cur_x - 1, cur_y, :left}
          ],
          nx >= 0,
          ny >= 0,
          nx < width,
          ny < height,
          Bitmap.get_pixel(bitmap, {nx, ny}) == 1 do
        {nx, ny, wx, wy}
      end

    case unvisited_neighbors do
      [] ->
        do_generate_maze(bitmap, tl(visited_cells))

      list ->
        {next_x, next_y, wall_x, wall_y} = Enum.random(list)

        bitmap
        |> Bitmap.set_pixel({wall_x, wall_y}, 0)
        |> Bitmap.set_pixel({next_x, next_y}, 0)
        |> do_generate_maze([{next_x, next_y} | visited_cells])
    end
  end
end
