defmodule Bitmap do
  require Integer

  @moduledoc """
  Functions for working with low-resolution monochrome  2D-bitmaps. You can
  create, crop, transform, invert, flip and overlay bitmaps as well as read
  and write bitmaps to and from files. Generators create mazes or apply
  game of life and other algorithms on the bitmaps.

  Bitmaps are stored in a simple matrix structure as maps with {x,y} coordinates
  as keys. Only 0 and 1 are allowed as values (no greyscaling or color).
  """

  defstruct meta: %{}, matrix: %{}

  defmacro defbitmap(lines) do
    quote do
      Bitmap.from_lines_of_text(unquote(lines), on: ?X, off: ?\s)
    end
  end

  defimpl Inspect, for: Bitmap do
    def inspect(bitmap, _opts) do
      width = bitmap.meta.width
      height = bitmap.meta.height

      # traverse pixels left to right, top to bottom
      delimiter = "+" <> String.duplicate("-", width) <> "+\n"

      lines =
        for y <- (height - 1)..0 do
          line =
            for x <- 0..(width - 1) do
              case Map.get(bitmap.matrix, {x, y}, 0) do
                0 -> ?\s
                _ -> ?X
              end
            end
            |> List.to_string()

          "|" <> line <> "|\n"
        end

      delimiter <> Enum.join(lines) <> delimiter
    end
  end

  @doc """
  Determine the effective bounding box of the bitmap
  """

  def bbox(bitmap) do
    pixels = Map.filter(bitmap.matrix, fn {_, value} -> value == 1 end) |> Map.keys()

    {min_x, min_y} =
      Enum.reduce(pixels, fn {x, y}, {min_x, min_y} ->
        {min(x, min_x), min(y, min_y)}
      end)

    {max_x, max_y} =
      Enum.reduce(pixels, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    {min_x, min_y, max_x, max_y}
  end

  @doc """
  Clip image to bounding box
  """
  def clip(bitmap) do
    {min_x, min_y, max_x, max_y} = bbox(bitmap)

    matrix =
      for x <- min_x..max_x, y <- min_y..max_y, into: %{} do
        {{x - min_x, y - min_y}, get_pixel(bitmap, {x, y})}
      end

    %Bitmap{
      meta: %{width: max_x - min_x + 1, height: max_y - min_y + 1},
      matrix: matrix
    }
  end

  @doc """
  Translate bitmap to new position.
  """
  def translate(bitmap, {dx, dy} = _transformation) do
    matrix =
      for x <- 0..(bitmap.meta.width - 1),
          y <- 0..(bitmap.meta.height - 1),
          pos_x = x + dx,
          pos_y = y + dy,
          pos_x >= 0,
          pos_y >= 0,
          pos_x < bitmap.meta.width,
          pos_y < bitmap.meta.height,
          into: %{} do
        {{pos_x, pos_y}, get_pixel(bitmap, {x, y})}
      end

    %Bitmap{
      meta: bitmap.meta,
      matrix: matrix
    }
  end

  def new(width, height) do
    %Bitmap{
      meta: %{height: height, width: width},
      matrix: %{}
    }
  end

  def invert(bitmap) do
    width = bitmap.meta.width
    height = bitmap.meta.height

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, 1 - get_pixel(bitmap, {x, y})}
      end

    %Bitmap{
      meta: bitmap.meta,
      matrix: matrix
    }
  end

  def flip_horizontally(bitmap) do
    width = bitmap.meta.width
    height = bitmap.meta.height

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, get_pixel(bitmap, {width - 1 - x, y})}
      end

    %Bitmap{
      meta: bitmap.meta,
      matrix: matrix
    }
  end

  def flip_vertically(bitmap) do
    width = bitmap.meta.width
    height = bitmap.meta.height

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, get_pixel(bitmap, {x, height - 1 - y})}
      end

    %Bitmap{
      meta: bitmap.meta,
      matrix: matrix
    }
  end

  def dimensions(bitmap) do
    {bitmap.meta.width, bitmap.meta.height}
  end

  def get_pixel(bitmap, {x, y} = _coordinate) do
    Map.get(bitmap.matrix, {x, y}, 0)
  end

  def set_pixel(bitmap, {x, y} = _coordinate, value) do
    matrix = Map.put(bitmap.matrix, {x, y}, value)

    %Bitmap{
      meta: bitmap.meta,
      matrix: matrix
    }
  end

  def toggle_pixel(bitmap, {x, y} = _coordinate) do
    set_pixel(bitmap, {x, y}, 1 - get_pixel(bitmap, {x, y}))
  end

  #
  # fill image beginning at a certain coordinate.
  # stop when hitting a set pixel
  #

  def fill(bitmap, {x, y}) do
    do_fill(bitmap, [{x, y}])
  end

  defp do_fill(bitmap, []) do
    bitmap
  end

  defp do_fill(bitmap, [{x, y} | rest]) do
    case get_pixel(bitmap, {x, y}) do
      1 ->
        bitmap

      0 ->
        bitmap = set_pixel(bitmap, {x, y}, 1)

        # look for clear neighbors

        empty_neighbors =
          for {nx, ny} <- [{x - 1, y}, {x + 1, y}, {x, y + 1}, {x, y - 1}],
              nx >= 0,
              ny >= 0,
              nx < bitmap.meta.width,
              ny < bitmap.meta.height,
              get_pixel(bitmap, {nx, ny}) == 0 do
            {nx, ny}
          end

        do_fill(bitmap, Enum.uniq(rest ++ empty_neighbors))
    end
  end

  # overlay one bitmap on another
  #
  # options:
  #  opaque: should the painted bitmap replace background bits
  #  bbox:   use bounding box info in bitmap to calculate target
  #
  # TODO
  # - support opaque: false option
  #

  def overlay(background, overlay, options \\ []) do
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
        opaque: false
      )

    # create new overlay matrix

    overlay_matrix =
      for x <- 0..(options[:bb_width] - 1),
          y <- 0..(options[:bb_height] - 1),
          bg_x = options[:cursor_x] + options[:bb_x_off] + x,
          bg_y = options[:cursor_y] + options[:bb_y_off] + y,
          bg_x >= 0,
          bg_x < background.meta.width,
          bg_y >= 0,
          bg_y < background.meta.height,
          into: %{} do
        pixel = get_pixel(overlay, {x, y})

        cond do
          pixel == 1 ->
            {{bg_x, bg_y}, 1}

          pixel == 0 and options[:opaque] ->
            {{bg_x, bg_y}, 0}

          pixel == 0 and not options[:opaque] ->
            {{bg_x, bg_y}, get_pixel(background, {bg_x, bg_y})}
        end
      end

    %Bitmap{
      meta: background.meta,
      matrix: Map.merge(background.matrix, overlay_matrix)
    }
  end

  @doc """
  Crop bitmap at a certain bounding box
  """
  def crop(bitmap, {start_x, start_y} = _coordinate, crop_width, crop_height)
      when crop_width > 0 and crop_height > 0 do
    cropped_matrix =
      for x <- 0..(crop_width - 1),
          y <- 0..(crop_height - 1),
          pos_x = start_x + x,
          pos_y = start_y + y,
          pos_x >= 0,
          pos_y >= 0,
          pos_x < bitmap.meta.width,
          pos_y < bitmap.meta.height,
          into: %{} do
        {{x, y}, get_pixel(bitmap, {pos_x, pos_y})}
      end

    %Bitmap{
      meta: %{width: crop_width, height: crop_height},
      matrix: cropped_matrix
    }
  end

  def crop_relative(bitmap, crop_width, crop_height, options \\ [])
      when crop_width > 0 and crop_height > 0 do
    options =
      Keyword.validate!(options,
        rel_y: :bottom,
        rel_x: :left
      )

    pos_x =
      case options[:rel_x] do
        :left -> 0
        :center -> div(bitmap.meta.width - crop_width, 2)
        :right -> bitmap.meta.width - crop_width
        rel_position -> raise("unkown relative position #{rel_position}")
      end

    pos_y =
      case options[:rel_y] do
        :top -> bitmap.meta.height - crop_height
        :middle -> div(bitmap.meta.height - crop_height, 2)
        :bottom -> 0
        rel_position -> raise("unkown relative position #{rel_position}")
      end

    crop(bitmap, {pos_x, pos_y}, crop_width, crop_height)
  end

  def random(width, height) do
    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{},
          do: {{x, y}, Enum.random(0..1)}

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  @doc """
  Apply Game of Life Algorithm to bitmap
  - a living cell surrounded by less than 2 living cells will die.
  - a living cell surrounded by more than 3 living cells will also die.
  - a dead cell surrounded by 3 living cells will be reborn.
  """
  def game_of_life(bitmap) do
    matrix =
      for x <- 0..(bitmap.meta.width - 1),
          y <- 0..(bitmap.meta.height - 1),
          into: %{} do
        number_of_neighbors =
          for dx <- [x - 1, x, x + 1],
              dy <- [y - 1, y, y + 1],
              dx >= 0,
              dy >= 0,
              dx < bitmap.meta.width,
              dy < bitmap.meta.height,
              not (dx == x and dy == y),
              get_pixel(bitmap, {dx, dy}) == 1,
              reduce: 0 do
            count -> count + 1
          end

        old_cell = get_pixel(bitmap, {x, y})

        new_cell =
          cond do
            old_cell == 1 and number_of_neighbors < 2 -> 0
            old_cell == 1 and number_of_neighbors > 3 -> 0
            old_cell == 0 and number_of_neighbors == 3 -> 1
            true -> old_cell
          end

        {{x, y}, new_cell}
      end

    %Bitmap{
      meta: %{width: bitmap.meta.width, height: bitmap.meta.height},
      matrix: matrix
    }
  end

  def frame(width, height) do
    h =
      for x <- 0..(width - 1),
          y <- [0, height - 1],
          do: {x, y}

    v = for(y <- 0..(height - 1), x <- [0, width - 1], do: {x, y})
    matrix = for {x, y} <- Enum.uniq(h ++ v), into: %{}, do: {{x, y}, 1}

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  # draw a line using bresenham algorithm

  def line(bitmap, {x1, y1}, {x2, y2}) do
    delta_x = abs(x2 - x1)
    sign_x = if x1 < x2, do: 1, else: -1
    delta_y = -abs(y2 - y1)
    sign_y = if y1 < y2, do: 1, else: -1

    threshold = delta_x + delta_y
    count = max(abs(delta_x), abs(delta_y))

    do_line(bitmap, {x1, y1}, {delta_x, sign_x, delta_y, sign_y}, threshold, count)
  end

  defp do_line(bitmap, _, _, _, count) when count < 0 do
    bitmap
  end

  defp do_line(bitmap, {x, y}, {delta_x, sign_x, delta_y, sign_y}, threshold, count) do
    {offset_x, thres_offset_x} = if threshold * 2 > delta_y, do: {sign_x, delta_y}, else: {0, 0}
    {offset_y, thres_offset_y} = if threshold * 2 < delta_x, do: {sign_y, delta_x}, else: {0, 0}

    set_pixel(bitmap, {x, y}, 1)
    |> do_line(
      {x + offset_x, y + offset_y},
      {delta_x, sign_x, delta_y, sign_y},
      threshold + thres_offset_x + thres_offset_y,
      count - 1
    )
  end

  @doc """
  Parse a Bitmap from a text file with multiline strings delimited by newline
  """

  def from_file(file) do
    File.read!(file) |> from_string()
  end

  @doc """
  Parse a Bitmap from a multiline string delimited by newline.
  """
  def from_string(string, options \\ []) do
    lines =
      string
      |> String.split("\n")
      |> Enum.reject(fn s -> s == "" end)
      |> Enum.map(fn s -> to_charlist(s) end)

    from_lines_of_text(lines, options)
  end

  def from_lines_of_text(lines, options \\ []) do
    on = Keyword.get(options, :on) || ?X
    off = Keyword.get(options, :off) || ?\s

    # convert lines provided as strings to charlist
    lines =
      Enum.map(lines, fn line ->
        if is_binary(line), do: to_charlist(line), else: line
      end)

    width = length(List.first(lines))

    if Enum.any?(lines, fn line -> length(line) != width end),
      do: raise("lines are of unequal length")

    height = length(lines)

    matrix =
      for {line, dy} <- Enum.with_index(lines, 1),
          {pixel, x} <- Enum.with_index(line, 0),
          into: %{} do
        value =
          case pixel do
            ^off ->
              0

            ^on ->
              1

            c ->
              raise "Invalid pixel character #{c} (#{on},#{off})"
          end

        {{x, height - dy}, value}
      end

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  def to_file(bitmap, file, options \\ []) do
    File.write!(file, to_text(bitmap, options))
  end

  @doc """
  Create text representation of the bitmap by rendering the pixels
  left to right, top to bottom in lines

  If the properties of the bitmap does not contain width and/or height
  values, these properties must be passed as options. If the property
  is available both as bitmap metadata as well as a parameter, the parameter
  overrides.

  Bounding box information is ignored.
  """
  def to_text(bitmap, options \\ []) do
    width = bitmap.meta.width
    height = bitmap.meta.height

    options =
      Keyword.validate!(options,
        on: ?X,
        off: ?\s
      )

    # traverse pixels left to right, top to bottom
    for y <- (height - 1)..0 do
      for x <- 0..(width - 1) do
        case get_pixel(bitmap, {x, y}) do
          0 -> options[:off]
          _ -> options[:on]
        end
      end
      |> Enum.concat('\n')
    end
    |> List.flatten()
    |> List.to_string()
  end

  @doc """
  Convert bitmap to binary representation where each pixels gets shoved into a single bit.
  Pixels are traversed from bottom to top, left to right.
  """

  # TODO
  # - add option to express binary composition direction (rtl/ltr, btt/ttb)
  #

  def to_binary(bitmap) do
    width = bitmap.meta.width
    height = bitmap.meta.height

    if rem(height, 8) != 0 do
      raise "height (#{height}) is not a multiple of 8 and therefore the bitmap can't be turned into a binary"
    end

    # traverse pixels bottom to top, left to right

    for x <- 0..(width - 1), y <- 0..(height - 1), into: <<>> do
      <<get_pixel(bitmap, {x, y})::1>>
    end
  end

  @doc """
  Create bitmap from binary representation where each pixels gets shoved into a single bit.
  Pixels are traversed from bottom to top, left to right.
  """

  def from_binary(data, width, height) do
    if byte_size(data) != div(width * height, 8),
      do: raise("Packet size (#{byte_size(data)}) does not match dimensions (width: #{width}, height: #{height})")

    pixels = for <<pixel::1 <- data>>, do: pixel
    columns = Enum.chunk_every(pixels, height)

    matrix =
      for {column, x} <- Enum.with_index(columns),
          {pixel, y} <- Enum.with_index(column),
          into: %{} do
        {{x, y}, pixel}
      end

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  def gradient_h(width, height) do
    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        value = if Enum.random(0..(width - 1)) <= x, do: 0, else: 1
        {{x, y}, value}
      end

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  def gradient_v(width, height) do
    matrix =
      for y <- 0..(height - 1), x <- 0..(width - 1), into: %{} do
        value = if Enum.random(0..(height - 1)) <= y, do: 0, else: 1
        {{x, y}, value}
      end

    %Bitmap{
      meta: %{width: width, height: height},
      matrix: matrix
    }
  end

  @doc """
  Generate a maze. Both width and height must be odd numbers
  """

  def maze(width, height) do
    if Integer.is_even(width) or Integer.is_even(height),
      do: raise("maze dimensions must be odd numbers")

    {start_x, start_y} = {Enum.random(1..(width - 1)//2), Enum.random(1..(height - 1)//2)}

    {entry_x, entry_y} = {0, Enum.random(1..(height - 1)//2)}
    {exit_x, exit_y} = {width - 1, Enum.random(1..(height - 1)//2)}

    Bitmap.new(width, height)
    |> Bitmap.invert()
    |> Bitmap.set_pixel({start_x, start_y}, 0)
    |> maze_gen([{start_x, start_y}])
    |> Bitmap.set_pixel({entry_x, entry_y}, 0)
    |> Bitmap.set_pixel({exit_x, exit_y}, 0)
  end

  defp maze_gen(bitmap, []) do
    bitmap
  end

  defp maze_gen(bitmap, visited_cells) do
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
          nx < bitmap.meta.width,
          ny < bitmap.meta.height,
          get_pixel(bitmap, {nx, ny}) == 1 do
        {nx, ny, wx, wy}
      end

    case unvisited_neighbors do
      [] ->
        maze_gen(bitmap, tl(visited_cells))

      list ->
        {next_x, next_y, wall_x, wall_y} = Enum.random(list)

        bitmap
        |> Bitmap.set_pixel({wall_x, wall_y}, 0)
        |> Bitmap.set_pixel({next_x, next_y}, 0)
        |> maze_gen([{next_x, next_y} | visited_cells])
    end
  end
end
