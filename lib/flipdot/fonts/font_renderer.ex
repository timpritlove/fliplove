defmodule FontRenderer do
  alias Flipdot.Kerning
  alias Flipdot.DisplayState

  def test(text, path) do
    font = parse_font(path)

    Bitmap.new(DisplayState.width(), DisplayState.height())
    |> render_text({4, 4}, font, text)
  end

  def parse_font(path) do
    {:ok, [font], _, _, _, _} = path |> File.read!() |> FontParser.parse_bdf()
    font
  end

  def render_text(bitmap, cursor, font, text) when is_binary(text) do
    render_text(bitmap, cursor, font, String.to_charlist(text))
  end

  def render_text(bitmap, _, _, []), do: bitmap

  def render_text(bitmap, {cursor_x, cursor_y} = cursor, font, [character | tail]) do
    case Map.get(font.characters, character, nil) do
      nil ->
        # skip non-existing characters
        if Map.get(font.characters, 0, nil) do
          render_text(bitmap, cursor, font, [0 | tail])
        else
          render_text(bitmap, cursor, font, tail)
        end

      char ->
        kerning =
          case tail do
            [] -> 0
            _ -> Kerning.get_kerning(font, [character, hd(tail)])
          end

        Bitmap.overlay(bitmap, char.bitmap,
          cursor_x: cursor_x,
          cursor_y: cursor_y,
          bb_width: Map.get(char, :bb_width, char.bitmap.meta.width),
          bb_height: Map.get(char, :bb_height, char.bitmap.meta.height),
          bb_x_off: Map.get(char, :bb_x_off, 0),
          bb_y_off: Map.get(char, :bb_y_off, 0),
          opaque: false
        )
        |> render_text(
          {cursor_x + Map.get(char, :dwx0, char.bitmap.meta.width + 1) + kerning,
           cursor_y + Map.get(char, :dwy0, 0)},
          font,
          tail
        )
    end
  end
end
