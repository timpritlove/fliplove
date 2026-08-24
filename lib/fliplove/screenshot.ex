defmodule Fliplove.Screenshot do
  @moduledoc """
  Renders a display bitmap into a PNG image that looks like the virtual
  display in the web interface, by compositing the same flipdot pixel tile
  images the web UI uses.
  """

  alias Fliplove.Bitmap

  # Same tile artwork the web interface uses on high-resolution screens
  @tile_size 24
  # Dark frame around the pixel grid, matching the web UI's display background (bg-gray-900)
  @padding 16
  @background {0x11, 0x18, 0x27}

  @doc """
  Renders the given display bitmap as a PNG binary.
  """
  def render(%Bitmap{} = bitmap) do
    on_tile = load_tile("on")
    off_tile = load_tile("off")

    width_px = bitmap.width * @tile_size + 2 * @padding
    height_px = bitmap.height * @tile_size + 2 * @padding

    vertical_padding = background_pixels(width_px * @padding)
    side_padding = background_pixels(@padding)

    # The topmost row of the display is y = height - 1, same as in the web UI
    rows =
      for y <- (bitmap.height - 1)..0//-1, scanline <- 0..(@tile_size - 1) do
        tiles =
          for x <- 0..(bitmap.width - 1) do
            tile = if Bitmap.get_pixel(bitmap, {x, y}) == 1, do: on_tile, else: off_tile
            elem(tile, scanline)
          end

        [side_padding, tiles, side_padding]
      end

    data = IO.iodata_to_binary([vertical_padding, rows, vertical_padding])

    Pngex.new(type: :rgb, depth: :depth8, width: width_px, height: height_px)
    |> Pngex.generate(data)
    |> IO.iodata_to_binary()
  end

  # Loads a pixel tile image and returns it as a tuple of scanline binaries
  # (RGB bytes), flattened against the background color.
  defp load_tile(state) do
    path =
      Application.app_dir(:fliplove, "priv/static/images/flipdot")
      |> Path.join("flipdot-pixel-#{state}-#{@tile_size}x#{@tile_size}.png")

    {:ok, image} = ExPng.Image.from_file(path)

    if image.width != @tile_size or image.height != @tile_size do
      raise "Tile image #{path} is #{image.width}x#{image.height}, expected #{@tile_size}x#{@tile_size}"
    end

    image.pixels
    |> Enum.map(fn row ->
      row |> Enum.map(&blend/1) |> IO.iodata_to_binary()
    end)
    |> List.to_tuple()
  end

  defp blend(<<r, g, b, a>>) do
    {bg_r, bg_g, bg_b} = @background
    <<blend_channel(r, bg_r, a), blend_channel(g, bg_g, a), blend_channel(b, bg_b, a)>>
  end

  defp blend_channel(channel, background, alpha) do
    div(channel * alpha + background * (255 - alpha), 255)
  end

  defp background_pixels(count) do
    {r, g, b} = @background
    :binary.copy(<<r, g, b>>, count)
  end
end
