defmodule Bitmap.Maze do
  @doc """
  Generate a maze. Both width and height must be odd numbers
  """
  require Integer
  require Logger

  def generate_maze(bitmap) do
    generate_maze(bitmap.width, bitmap.height)
  end

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

  # maze solver

  def solve_maze(bitmap, opts \\ []) do
    opts = Keyword.validate!(opts, mode: :parallel)

    Stream.resource(
      fn -> {:dead_end, bitmap, opts} end,
      fn
        {:close_doors, bitmap, dead_ends, opts} ->
          case opts[:mode] do
            :parallel ->
              bitmap =
                for {_, {nx, ny}} <- dead_ends, reduce: bitmap do
                  bitmap -> Bitmap.set_pixel(bitmap, {nx, ny}, 1)
                end

              {[bitmap], {:dead_end, bitmap, opts}}

            :one_by_one ->
              {_, {nx, ny}} = hd(dead_ends)
              bitmap = Bitmap.set_pixel(bitmap, {nx, ny}, 1)
              {[bitmap], {:dead_end, bitmap, opts}}
          end

        {:dead_end, bitmap, opts} ->
          {width, height} = Bitmap.dimensions(bitmap)

          # find dead ends

          dead_ends =
            for x <- Range.new(1, width - 2, 2),
                y <- Range.new(1, height - 2, 2),
                Bitmap.get_pixel(bitmap, {x, y}) == 0,
                open_paths =
                  (for {nx, ny} <- [{x, y + 1}, {x, y - 1}, {x - 1, y}, {x + 1, y}],
                       Bitmap.get_pixel(bitmap, {nx, ny}) == 0 do
                     {nx, ny}
                   end),
                length(open_paths) == 1 do
              {{x, y}, hd(open_paths)}
            end

          case dead_ends do
            [] ->
              {:halt, nil}

            dead_ends ->
              case opts[:mode] do
                :parallel ->
                  bitmap =
                    for {{x, y}, _} <- dead_ends, reduce: bitmap do
                      bitmap -> Bitmap.set_pixel(bitmap, {x, y}, 1)
                    end

                  {[bitmap], {:close_doors, bitmap, dead_ends, opts}}

                :one_by_one ->
                  dead_ends = Enum.shuffle(dead_ends)
                  {{x, y}, _} = hd(dead_ends)
                  bitmap = Bitmap.set_pixel(bitmap, {x, y}, 1)
                  {[bitmap], {:close_doors, bitmap, dead_ends, opts}}
              end
          end
      end,
      fn _ -> nil end
    )
  end
end
