defmodule SymbolImporter do
  alias Flipdot.Bitmap

  @moduledoc """
  Extracts 16x16 symbols from a PNG file and saves them as individual bitmap text files.

  The PNG file should follow this format:
  - 8 pixel wide border around the entire image
  - 8 pixel wide delimiters between symbols
  - 16x16 pixel symbol areas
  - Dark pixels (grayscale value < 128) are treated as "off" state
  - Light pixels (grayscale value >= 128) are treated as "on" state

  ## Example Usage

      # Process a PNG file, saving symbols to the default "symbols" directory
      SymbolImporter.process_file("path/to/symbols.png")

      # Process a PNG file with custom output directory
      SymbolImporter.process_file("path/to/symbols.png", "output/symbols")

  ## Output Format

  The module will create one text file per non-empty symbol, using the following naming convention:
  - Files are named as "ROW_COL.txt" (e.g., "002_004.txt" for row 2, column 4)
  - Row and column numbers are 1-based and padded with zeros
  - Empty symbols (all dark pixels) are skipped
  - Each text file contains a bitmap representation where:
    * 'X' represents an "on" pixel (light)
    * Space represents an "off" pixel (dark)
  """

  require Logger

  @symbol_size 16
  @default_border_size 8  # Default border size around the image
  @default_distance 8     # Default distance between symbols
  @threshold 128  # Grayscale values above this are considered "white"

  @doc """
  Processes a PNG file and extracts all non-empty 16x16 symbols, saving them as bitmap text files.

  ## Parameters

    * `png_path` - Path to the PNG file to process
    * `output_dir` - Directory where the bitmap text files will be saved (default: "symbols")
    * `opts` - Options for processing:
      * `:border` - Number of pixels to ignore around the image (default: #{@default_border_size})
      * `:distance` - Number of pixels between symbols (default: #{@default_distance})

  ## Returns

    Returns `:ok` if successful.
    Raises an error if:
    - The PNG file cannot be read or decoded
    - The output directory cannot be created

  ## Example

      # With default border and distance
      iex> SymbolImporter.process_file("symbols.png", "output/bitmaps")
      :ok

      # With custom border and distance
      iex> SymbolImporter.process_file("symbols.png", "output/bitmaps", border: 10, distance: 6)
      :ok
  """
  def process_file(png_path, output_dir \\ "symbols", opts \\ []) do
    border = Keyword.get(opts, :border, @default_border_size)
    distance = Keyword.get(opts, :distance, @default_distance)

    # Ensure output directory exists
    File.mkdir_p!(output_dir)

    # Read and decode PNG
    case ExPng.Image.from_file(png_path) do
      {:ok, image} ->
        Logger.info("Processing PNG file: #{png_path}")
        Logger.info("Image dimensions: #{image.width}x#{image.height}")
        Logger.info("Using border size: #{border}, distance between symbols: #{distance}")

        # Calculate number of complete symbols that can fit
        # For n symbols we need: 2*border + n*symbol_size + (n-1)*distance ≤ dimension
        # Solving for n: n ≤ (dimension - 2*border + distance)/(symbol_size + distance)
        usable_width = image.width - 2 * border + distance
        usable_height = image.height - 2 * border + distance

        symbols_per_row = div(usable_width, @symbol_size + distance)
        symbols_per_col = div(usable_height, @symbol_size + distance)

        Logger.info("Found space for #{symbols_per_row}x#{symbols_per_col} symbols")

        # Process each symbol position
        for row <- 0..(symbols_per_col - 1),
            col <- 0..(symbols_per_row - 1) do
          # Calculate pixel coordinates for this symbol
          x_start = border + col * (@symbol_size + distance)
          y_start = border + row * (@symbol_size + distance)

          Logger.info("Processing symbol at position (#{row + 1},#{col + 1}), starting at (#{x_start},#{y_start})")

          # Extract symbol pixels
          symbol_pixels = extract_symbol_pixels(image, x_start, y_start)

          # Process symbol if not empty
          unless symbol_empty?(symbol_pixels) do
            # Convert to bitmap
            bitmap = pixels_to_bitmap(symbol_pixels)

            # Generate filename based on position (1-based indexing for filenames)
            filename = Path.join(output_dir, "#{pad_number(row + 1)}_#{pad_number(col + 1)}.txt")

            Logger.info("Saving non-empty symbol to #{filename}")

            # Save bitmap to file
            Bitmap.to_file(bitmap, filename)
          end
        end

        :ok

      {:error, reason} ->
        Logger.error("Failed to read or decode the PNG file: #{inspect(reason)}")
        {:error, "Failed to read or decode the PNG file"}
    end
  end

  # Extracts a 16x16 pixel array for a symbol at the given coordinates
  defp extract_symbol_pixels(image, x_start, y_start) do
    # Read pixels from bottom to top to flip the image vertically
    for y <- (@symbol_size - 1)..0 do
      for x <- 0..(@symbol_size - 1) do
        ExPng.Image.at(image, {x_start + x, y_start + y})
      end
    end
  end

  # Checks if a symbol is empty (all dark pixels)
  defp symbol_empty?(pixels) do
    pixels
    |> List.flatten()
    |> Enum.all?(fn pixel -> is_dark_pixel?(pixel) end)
  end

  # Converts pixel data to a Bitmap struct
  defp pixels_to_bitmap(pixels) do
    matrix =
      for {row, y} <- Enum.with_index(pixels),
          {pixel, x} <- Enum.with_index(row),
          into: %{} do
        value = if is_dark_pixel?(pixel), do: 0, else: 1
        {{x, y}, value}
      end

    Bitmap.new(@symbol_size, @symbol_size, matrix)
  end

  # Helper to determine if a pixel is considered dark
  defp is_dark_pixel?(<<r, g, b, _a>>) do
    # Convert RGB to grayscale using standard luminance formula
    grayscale = round(0.299 * r + 0.587 * g + 0.114 * b)
    grayscale < @threshold
  end

  defp is_dark_pixel?(<<r, g, b>>) do
    is_dark_pixel?(<<r, g, b, 255>>)
  end

  # Handle tuple format for backwards compatibility
  defp is_dark_pixel?({r, g, b, _a}) do
    # Convert RGB to grayscale using standard luminance formula
    grayscale = round(0.299 * r + 0.587 * g + 0.114 * b)
    grayscale < @threshold
  end

  # Handle RGB pixels without alpha
  defp is_dark_pixel?({r, g, b}) do
    is_dark_pixel?({r, g, b, 255})
  end

  # Pads a number with leading zeros to ensure consistent filenames
  defp pad_number(num) do
    num
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end
end
