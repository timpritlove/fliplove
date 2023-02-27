defmodule FontRenderer do
  def test(text, path) do
    font = parse_font(path)
    bitmap = Bitmap.new(115, 16)

    render_text(bitmap, 4, 4, font, text)
  end

  def parse_font(path) do
    {:ok, [font], _, _, _, _} = path |> File.read!() |> FontParser.parse_bdf()
    font
  end

  def render_text(bitmap, cursor_x, cursor_y, font, text) when is_binary(text) do
    render_text(bitmap, cursor_x, cursor_y, font, String.to_charlist(text))
  end

  def render_text(bitmap, _, _, _, []), do: bitmap

  def render_text(bitmap, cursor_x, cursor_y, font, [character | tail]) do
    char = font.characters[character]

    new_bitmap =
      Bitmap.overlay(bitmap, char.bitmap,
        cursor_x: cursor_x,
        cursor_y: cursor_y,
        bb_width: char.bb_width,
        bb_height: char.bb_height,
        bb_x_off: char.bb_x_off,
        bb_y_off: char.bb_y_off
      )

    new_cursor_x = cursor_x + char.dwx0
    new_cursor_y = cursor_y + char.dwy0

    render_text(new_bitmap, new_cursor_x, new_cursor_y, font, tail)
  end
end
