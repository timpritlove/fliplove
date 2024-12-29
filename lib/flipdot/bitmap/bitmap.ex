defmodule Flipdot.Bitmap do
  require Integer

  @moduledoc """
  Basic functions for working with low-resolution monochrome 2D-bitmaps. You can
  create, crop, transform, invert, flip and overlay bitmaps as well as read
  and write bitmaps to and from strings or files.

  Bitmaps are stored in a simple matrix structure as maps with {x,y} coordinates
  as keys. Only 0 and 1 are allowed as values (no greyscaling or color).
  """

  defstruct width: nil, height: nil, matrix: %{}, baseline_x: 0, baseline_y: 0

  @doc """
  Macro to define a monochrome bitmap inline as lines of text.
  Default characters are space for 0 and 'X' for 1. This can
  be overriden with the on: and off: parametes accordingly.
  All lines must have the same length.

  Options:
    - on: character to represent 1 (default: 'X')
    - off: character to represent 0 (default: space)
    - baseline_x: horizontal baseline position (default: 0)
    - baseline_y: vertical baseline position (default: 0)
  """
  defmacro defbitmap(lines, opts \\ []) do
    quote do
      bitmap = Flipdot.Bitmap.from_lines_of_text(unquote(lines),
        on: Keyword.get(unquote(opts), :on, ?X),
        off: Keyword.get(unquote(opts), :off, ?\s),
        baseline_x: Keyword.get(unquote(opts), :baseline_x, 0),
        baseline_y: Keyword.get(unquote(opts), :baseline_y, 0)
      )
      # Ensure we return a proper Bitmap struct
      case bitmap do
        %Flipdot.Bitmap{} -> bitmap
        map when is_map(map) -> struct(Flipdot.Bitmap, Map.merge(%Flipdot.Bitmap{}, map))
      end
    end
  end

  defimpl Inspect, for: Flipdot.Bitmap do
    def inspect(bitmap, _opts) do
      # Use full dimensions instead of bounding box
      width = bitmap.width
      height = bitmap.height

      # Create top delimiter with baseline marker if needed
      top_line = for x <- 0..(width-1) do
        if x == -bitmap.baseline_x, do: ?+, else: ?-
      end
      delimiter = "+" <> List.to_string(top_line) <> "+\n"

      lines =
        for y <- (height-1)..0//-1 do
          # Use '+' for baseline markers, '|' for other lines
          left_border = if y == -bitmap.baseline_y, do: ?+, else: ?|
          right_border = if y == -bitmap.baseline_y, do: ?+, else: ?|

          line =
            for x <- 0..(width-1) do
              case Map.get(bitmap.matrix, {x, y}, 0) do
                0 -> ?\s
                _ -> ?X
              end
            end
            |> List.to_string()

          <<left_border>> <> line <> <<right_border>> <> "\n"
        end

      # Create bottom delimiter with baseline marker if needed
      bottom_line = for x <- 0..(width-1) do
        if x == -bitmap.baseline_x, do: ?+, else: ?-
      end
      bottom_delimiter = "+" <> List.to_string(bottom_line) <> "+\n"

      "\n" <> delimiter <> Enum.join(lines) <> bottom_delimiter
    end
  end

  # basic operations

  @doc """
  Create a bitmap with given width and height and initialized by a matrix of pixels.
  The matrix must be a map with coordinates as keys given as a tuple {x,y} and a value
  of 0 or 1.

  Options:
    - baseline_x: horizontal baseline position (default: 0)
    - baseline_y: vertical baseline position (default: 0)
  """
  def new(width, height) when is_integer(width) and is_integer(height) do
    new(width, height, %{}, [])
  end

  def new(width, height, matrix) when is_integer(width) and is_integer(height) and is_map(matrix) do
    new(width, height, matrix, [])
  end

  def new(width, height, options) when is_integer(width) and is_integer(height) and is_list(options) do
    new(width, height, %{}, options)
  end

  def new(width, height, matrix, options)
      when is_integer(width) and is_integer(height) and is_map(matrix) do
    options = Keyword.validate!(options, baseline_x: 0, baseline_y: 0)

    if valid_matrix?(matrix) do
      %Flipdot.Bitmap{
        width: width,
        height: height,
        matrix: matrix,
        baseline_x: options[:baseline_x],
        baseline_y: options[:baseline_y]
      }
    else
      raise "Invalid matrix"
    end
  end

  defp valid_matrix?(matrix) do
    matrix
    |> Map.keys()
    |> Enum.all?(fn key ->
      case key do
        {x, y} when is_integer(x) and is_integer(y) ->
          case Map.get(matrix, key) do
            0 -> true
            1 -> true
            _ -> false
          end

        _ ->
          false
      end
    end)
  end

  @doc """
  Returns the configured width of bitmap.
  """

  def width(bitmap) do
    bitmap.width
  end

  @doc """
  Returns the configured height of bitmap.
  """

  def height(bitmap) do
    bitmap.height
  end

  @doc """
  Returns the configured width and height of bitmap as a tuple.
  """
  def dimensions(bitmap) do
    {bitmap.width, bitmap.height}
  end

  # individual pixel manipulation

  @doc """
  The current value of the pixel at given `coordinate`.
  The coordinate must be passed as a tuple {x,y}.
  """
  def get_pixel(bitmap, {x, y} = _coordinate) do
    Map.get(bitmap.matrix, {x, y}, 0)
  end

  @doc """
  Set the pixel at given coordinate to `value`.
  The coordinate must be passed as a tuple {x,y}.
  """
  def set_pixel(bitmap, {x, y} = _coordinate, value) do
    new(width(bitmap), height(bitmap), Map.put(bitmap.matrix, {x, y}, value))
  end

  @doc """
  Toggle the value of the pixel at given coordinate.
  The coordinate must be passed as a tuple {x,y}.
  """
  def toggle_pixel(bitmap, {x, y} = _coordinate) do
    set_pixel(bitmap, {x, y}, 1 - get_pixel(bitmap, {x, y}))
  end

  # streaming

  @doc """
  Create a stream with a given bitmap filter function on bitmap.
  """
  def filter_stream(bitmap, filter) when is_function(filter, 1) do
    Stream.resource(
      fn -> bitmap end,
      fn bitmap ->
        bitmap = filter.(bitmap)
        {[bitmap], bitmap}
      end,
      fn foo -> foo end
    )
  end

  @doc """
  Determine the effective bounding box of the bitmap.
  Returns the bounding box as min/max coordinate in a tuple.
  Returns {0, 0, 0, 0} for empty bitmaps.
  """

  def bbox(bitmap) do
    pixels = Map.filter(bitmap.matrix, fn {_, value} -> value == 1 end) |> Map.keys()

    if Enum.empty?(pixels) do
      {0, 0, 0, 0}  # Return zero bounds for empty bitmap
    else
      [{first_x, first_y} | rest] = pixels

      {min_x, min_y} =
        Enum.reduce(rest, {first_x, first_y}, fn {x, y}, {min_x, min_y} ->
          {min(x, min_x), min(y, min_y)}
        end)

      {max_x, max_y} =
        Enum.reduce(rest, {first_x, first_y}, fn {x, y}, {max_x, max_y} ->
          {max(x, max_x), max(y, max_y)}
        end)

      {min_x, min_y, max_x, max_y}
    end
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

    new(max_x - min_x + 1, max_y - min_y + 1, matrix)
  end

  @doc """
  Translate bitmap to new position.
  """
  def translate(bitmap, {dx, dy} = _transformation) do
    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          pos_x = x + dx,
          pos_y = y + dy,
          pos_x >= 0,
          pos_y >= 0,
          pos_x < width,
          pos_y < height,
          into: %{} do
        {{pos_x, pos_y}, get_pixel(bitmap, {x, y})}
      end

    new(width, height, matrix)
  end

  @doc """
  Invert the bitmap.
  """
  def invert(bitmap) do
    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, 1 - get_pixel(bitmap, {x, y})}
      end

    new(width, height, matrix)
  end

  @doc """
  Flip the bitmap horizontally.
  """
  def flip_horizontally(bitmap) do
    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, get_pixel(bitmap, {width - 1 - x, y})}
      end

    new(width, height, matrix)
  end

  @doc """
  Flip the bitmap vertically.
  """

  def flip_vertically(bitmap) do
    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        {{x, y}, get_pixel(bitmap, {x, height - 1 - y})}
      end

    new(width, height, matrix)
  end

  @doc """
    Fill image beginning at a certain coordinate.
    stop when hitting a set pixel
  """

  def fill(bitmap, {x, y}) do
    do_fill(bitmap, [{x, y}])
  end

  defp do_fill(bitmap, []) do
    bitmap
  end

  defp do_fill(bitmap, [{x, y} | rest]) do
    {width, height} = dimensions(bitmap)

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
              nx < width,
              ny < height,
              get_pixel(bitmap, {nx, ny}) == 0 do
            {nx, ny}
          end

        do_fill(bitmap, Enum.uniq(rest ++ empty_neighbors))
    end
  end

  @doc """
  Overlay one bitmap on another

  Options:
   opaque: should the painted bitmap replace background bits
   bbox:   use bounding box info in bitmap to calculate target
  """

  # TODO
  # - support opaque: false option
  #

  def overlay(bitmap, overlay, options \\ []) do
    # Allow cursor position and bounding box in bitmap
    # to be passed as parameters.
    # default to unshifted positions with all pixels included.
    {width, height} = dimensions(bitmap)

    options =
      Keyword.validate!(options,
        cursor_x: 0,
        cursor_y: 0,
        bb_width: width(overlay),
        bb_height: height(overlay),
        bb_x_off: 0,
        bb_y_off: 0,
        opaque: false
      )

    # Create new overlay matrix
    overlay_matrix =
      for x <- 0..(options[:bb_width] - 1),
          y <- 0..(options[:bb_height] - 1),
          bg_x = options[:cursor_x] + options[:bb_x_off] + x,
          bg_y = options[:cursor_y] + options[:bb_y_off] + y,
          bg_x >= 0,
          bg_x < width,
          bg_y >= 0,
          bg_y < height do
        pixel = get_pixel(overlay, {x, y})
        value = cond do
          pixel == 1 -> 1
          pixel == 0 and options[:opaque] -> 0
          pixel == 0 and not options[:opaque] -> get_pixel(bitmap, {bg_x, bg_y})
        end
        {{bg_x, bg_y}, value}
      end
      |> Map.new()

    # Create the final bitmap with the overlaid pixels
    new(width, height, Map.merge(bitmap.matrix, overlay_matrix))
  end

  @doc """
  Crop bitmap at a certain bounding box
  """
  def crop(bitmap, {start_x, start_y} = _coordinate, crop_width, crop_height)
      when crop_width > 0 and crop_height > 0 do
    {width, height} = dimensions(bitmap)

    cropped_matrix =
      for x <- 0..(crop_width - 1),
          y <- 0..(crop_height - 1),
          pos_x = start_x + x,
          pos_y = start_y + y,
          pos_x >= 0,
          pos_y >= 0,
          pos_x < width,
          pos_y < height,
          into: %{} do
        {{x, y}, get_pixel(bitmap, {pos_x, pos_y})}
      end

    new(crop_width, crop_height, cropped_matrix)
  end

  @doc """
  Crop bitmap relative to given bitmap.

  Relative position in horizontal direction: :left, :center, :right
  Relative position in vertical direction: :top, :middle, :bottom
  """

  def crop_relative(bitmap, crop_width, crop_height, options \\ [])
      when crop_width > 0 and crop_height > 0 do
    {width, height} = dimensions(bitmap)

    options =
      Keyword.validate!(options,
        rel_x: :left,
        rel_y: :bottom
      )

    pos_x =
      case options[:rel_x] do
        :left -> 0
        :center -> div(width - crop_width, 2)
        :right -> width - crop_width
        rel_position -> raise("unkown relative position #{rel_position}")
      end

    pos_y =
      case options[:rel_y] do
        :top -> height - crop_height
        :middle -> div(height - crop_height, 2)
        :bottom -> 0
        rel_position -> raise("unkown relative position #{rel_position}")
      end

    crop(bitmap, {pos_x, pos_y}, crop_width, crop_height)
  end

  @doc """
  Scale bitmap to a certain factor
  """

  def scale(bitmap, factor) when is_integer(factor) and factor > 0 do
    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          value = get_pixel(bitmap, {x, y}),
          dx <- 0..(factor - 1),
          dy <- 0..(factor - 1),
          into: %{} do
        {{x * factor + dx, y * factor + dy}, value}
      end

    new(width * factor, height * factor, matrix)
  end

  @doc """
  Rotate the bitmap by 90 degrees
  direction is either :cw (90 degress, default) or :ccw (-90 degress)
  """

  def rotate(bitmap, options \\ []) do
    options = Keyword.validate!(options, direction: :cw)

    {width, height} = dimensions(bitmap)

    matrix =
      for x <- 0..(height - 1), y <- 0..(width - 1), into: %{} do
        {{x, y},
         get_pixel(
           bitmap,
           case options[:direction] do
             :cw -> {width - 1 - y, x}
             :ccw -> {y, height - 1 - x}
           end
         )}
      end

    new(height, width, matrix)
  end

  @doc """
  Create a bitmap with randomly set pixels
  """

  def random(width, height) do
    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{},
          do: {{x, y}, Enum.random(0..1)}

    new(width, height, matrix)
  end

  @doc """
  Create a bitmap surrounded by a frame
  """
  def frame(width, height) do
    h =
      for x <- 0..(width - 1),
          y <- [0, height - 1],
          do: {x, y}

    v = for(y <- 0..(height - 1), x <- [0, width - 1], do: {x, y})
    matrix = for {x, y} <- Enum.uniq(h ++ v), into: %{}, do: {{x, y}, 1}

    new(width, height, matrix)
  end

  # draw a line using bresenham algorithm

  @doc """
  Draw line from one coordinate to another.
  """

  def line(bitmap, {x1, y1} = _from, {x2, y2} = _to) do
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

  @doc """
  Create a bitmap from lines of text, where each character in the line represents a pixel.
  By default, treats "1" or "X" as on pixels and "0" or " " as off pixels.
  Can be overridden with :on and :off options which can be single characters or lists of characters.
  """
  def from_lines_of_text(lines, options \\ []) do
    # Allow override but provide smart defaults
    baseline_x = Keyword.get(options, :baseline_x, 0)
    baseline_y = Keyword.get(options, :baseline_y, 0)
    on = Keyword.get(options, :on, [?X, ?1]) |> List.wrap()
    off = Keyword.get(options, :off, [?\s, ?0]) |> List.wrap()

    # Convert any strings to charlists
    lines =
      Enum.map(lines, fn line ->
        cond do
          is_binary(line) -> to_charlist(line)
          true -> line
        end
      end)

    width = length(List.first(lines))

    if Enum.any?(lines, fn line -> length(line) != width end) do
      formatted_lines = Enum.map(lines, fn line -> "|#{line}|" end)
      raise("lines are of unequal length:\n#{Enum.join(formatted_lines, "\n")}")
    end

    height = length(lines)

    matrix =
      for {line, y} <- Enum.with_index(Enum.reverse(lines)),
          {pixel, x} <- Enum.with_index(line, 0),
          into: %{} do
        value =
          cond do
            pixel in on -> 1
            pixel in off -> 0
            true -> raise "Invalid pixel character #{inspect(<<pixel>>)} (expected one of #{inspect(Enum.map(on, &<<&1>>))} for on, one of #{inspect(Enum.map(off, &<<&1>>))} for off)"
          end

        {{x, y}, value}
      end

    new(width, height, matrix, baseline_x: baseline_x, baseline_y: baseline_y)
  end

  def to_file(bitmap, file, options \\ []) do
    File.write!(file, to_text(bitmap, options))
  end

  @doc """
  Create PNG representation of the bitmap by rendering the pixels
  left to right, top to bottom in lines
  """
  def to_png(bitmap, options \\ []) do
    options =
      Keyword.validate!(options,
        bg_color: {0, 0, 0},
        fg_color: {0xFF, 0xFF, 0}
      )

    {width, height} = dimensions(bitmap)

    # traverse pixels left to right, top to bottom
    pixels =
      for y <- (height - 1)..0 do
        for x <- 0..(width - 1) do
          case get_pixel(bitmap, {x, y}) do
            0 -> options[:bg_color]
            1 -> options[:fg_color]
          end
        end
      end
      |> List.flatten()

    Pngex.new(
      type: :rgb,
      depth: :depth8,
      width: width,
      height: height
    )
    |> Pngex.generate(pixels)
  end

  @doc """
  Create SVG representation of the bitmap by rendering the pixels
  left to right, top to bottom in lines
  """
  def to_svg(bitmap, opts \\ []) do
    {width, height} = dimensions(bitmap)

    opts =
      Keyword.validate!(opts,
        width: width,
        height: height,
        scale: 1
      )

    svg_header = """
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="#{opts[:width] * opts[:scale]}px" height="#{opts[:height] * opts[:scale]}px"
            viewbox="0 0 #{width} #{height}">
    """

    svg_footer = """
          </svg>
    """

    # traverse pixels left to right, top to bottom
    svg_pixels =
      for y <- (height - 1)..0//-1 do
        for x <- 0..(width - 1),
            pixel = get_pixel(bitmap, {x, y}),
            pixel == 1 do
          """
          <rect x="#{x}" y="#{height - 1 - y}" width="0.8" height="0.8" />
          """
        end
      end

    svg_header <> Enum.join(svg_pixels) <> svg_footer
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
    {width, height} = dimensions(bitmap)

    options =
      Keyword.validate!(options,
        on: ?X,
        off: ?\s
      )

    # traverse pixels left to right, top to bottom
    for y <- (height - 1)..0//-1 do
      row = for x <- 0..(width - 1) do
        case get_pixel(bitmap, {x, y}) do
          0 -> options[:off]
          _ -> options[:on]
        end
      end

      row ++ [?\n]  # Append newline character to the row
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
    {width, height} = dimensions(bitmap)

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

    new(width, height, matrix)
  end

  @doc """
  Draw a gradient from left to right using randomized dithering
  """
  def gradient_h(bitmap) do
    gradient_h(bitmap.width, bitmap.height)
  end

  def gradient_h(width, height) do
    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        value = if Enum.random(0..(width - 1)) <= x, do: 0, else: 1
        {{x, y}, value}
      end

    new(width, height, matrix)
  end

  @doc """
  Draw a gradient from top to bottom using randomized dithering
  """
  def gradient_v(bitmap) do
    gradient_v(bitmap.width, bitmap.height)
  end

  def gradient_v(width, height) do
    matrix =
      for y <- 0..(height - 1), x <- 0..(width - 1), into: %{} do
        value = if Enum.random(0..(height - 1)) <= y, do: 0, else: 1
        {{x, y}, value}
      end

    new(width, height, matrix)
  end

  @doc """
  Returns the number of pixels that differ between two bitmaps.
  Both bitmaps must have the same dimensions.
  """
  def diff_count(bitmap1, bitmap2) do
    if dimensions(bitmap1) != dimensions(bitmap2) do
      raise "Bitmaps must have the same dimensions"
    end

    {width, height} = dimensions(bitmap1)

    for x <- 0..(width - 1),
        y <- 0..(height - 1),
        get_pixel(bitmap1, {x, y}) != get_pixel(bitmap2, {x, y}),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  @doc """
  Merge two bitmaps, allowing the result to grow as needed.
  The second bitmap is positioned relative to the first one using the offset parameters.
  Returns a new bitmap that encompasses both inputs.

  Options:
    - offset_x: horizontal offset for bitmap2 (default: 0)
    - offset_y: vertical offset for bitmap2 (default: 0)
    - preserve_baseline: whether to preserve baseline information instead of normalizing coordinates (default: false)
  """
  def merge(bitmap1, bitmap2, options \\ []) do
    options =
      Keyword.validate!(options,
        offset_x: 0,
        offset_y: 0,
        preserve_baseline: false
      )

    # If either bitmap is empty, return the other one
    cond do
      Enum.empty?(bitmap1.matrix) -> bitmap2
      Enum.empty?(bitmap2.matrix) -> bitmap1
      true ->
        # Get the bounds of both bitmaps
        {min_x1, min_y1, max_x1, max_y1} = bbox(bitmap1)
        {min_x2, min_y2, max_x2, max_y2} = bbox(bitmap2)

        # Calculate the bounds of the merged bitmap
        offset_x = options[:offset_x]
        offset_y = options[:offset_y]

        if options[:preserve_baseline] do
          # When preserving baseline, adjust coordinates based on baseline differences
          baseline_y_diff = bitmap2.baseline_y - bitmap1.baseline_y
          baseline_x_diff = bitmap2.baseline_x - bitmap1.baseline_x

          # Adjust bitmap2's coordinates by both the explicit offset and baseline differences
          matrix2 =
            bitmap2.matrix
            |> Enum.map(fn {{x, y}, v} -> {{x + offset_x + baseline_x_diff, y + offset_y + baseline_y_diff}, v} end)
            |> Map.new()

          # Merge the matrices, with bitmap2 taking precedence
          merged_matrix = Map.merge(bitmap1.matrix, matrix2)

          # Calculate dimensions based on actual coordinates, including negative ones
          {merged_min_x, merged_min_y, merged_max_x, merged_max_y} =
            merged_matrix
            |> Map.keys()
            |> Enum.reduce({min_x1, min_y1, max_x1, max_y1}, fn {x, y}, {min_x, min_y, max_x, max_y} ->
              {min(x, min_x), min(y, min_y), max(x, max_x), max(y, max_y)}
            end)

          # When preserving baseline, we keep bitmap1's baseline
          %Flipdot.Bitmap{
            width: merged_max_x - merged_min_x + 1,
            height: merged_max_y - merged_min_y + 1,
            matrix: merged_matrix,
            baseline_x: bitmap1.baseline_x,
            baseline_y: bitmap1.baseline_y
          }
        else
          # When not preserving baseline, normalize coordinates to start at 0,0
          min_x = min(min_x1, min_x2 + offset_x)
          min_y = min(min_y1, min_y2 + offset_y)
          max_x = max(max_x1, max_x2 + offset_x)
          max_y = max(max_y1, max_y2 + offset_y)

          matrix2 =
            bitmap2.matrix
            |> Enum.map(fn {{x, y}, v} -> {{x + offset_x, y + offset_y}, v} end)
            |> Map.new()

          merged_matrix = Map.merge(bitmap1.matrix, matrix2)

          normalize(
            %Flipdot.Bitmap{
              width: max_x - min_x + 1,
              height: max_y - min_y + 1,
              matrix: merged_matrix,
              baseline_x: 0,
              baseline_y: 0
            }
          )
        end
    end
  end

  @doc """
  Normalize a bitmap's coordinates to start at 0,0.
  This will remove any baseline offset but preserve the relative positions of all pixels.
  """
  def normalize(bitmap) do
    {min_x, min_y, max_x, max_y} = bbox(bitmap)

    # When we shift coordinates up by min_y, the baseline_y should be adjusted down by min_y
    # When we shift coordinates left by min_x, the baseline_x should be adjusted right by min_x
    new(max_x - min_x + 1, max_y - min_y + 1,
      bitmap.matrix
      |> Enum.map(fn {{x, y}, v} -> {{x - min_x, y - min_y}, v} end)
      |> Map.new(),
      baseline_x: bitmap.baseline_x + min_x,
      baseline_y: bitmap.baseline_y + min_y
    )
  end
end
