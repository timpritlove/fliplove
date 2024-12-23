defmodule Flipdot.Font.Renderer do
  alias Flipdot.Font
  alias Flipdot.Font.Kerning
  require Logger

  @type alignment :: :left | :center | :right
  @type vertical_alignment :: :top | :middle | :bottom

  @doc """
  Renders text into a new bitmap that is exactly the size needed.
  Returns a bitmap sized to fit the rendered text. Returns an empty 0x0 bitmap for empty text.
  """
  def create_text(font, text) when is_binary(text) do
    create_text(font, String.to_charlist(text))
  end

  def create_text(_font, []), do: Bitmap.new(0, 0)

  def create_text(font, text) when is_list(text) do
    render_text_unconstrained(Bitmap.new(0, 0), {0, 0}, font, text)
  end

  @doc """
  Places text onto an existing bitmap with specified alignment.
  """
  def place_text(target_bitmap, font, text, opts \\ []) do
    alignment = Keyword.get(opts, :align, :left)
    valign = Keyword.get(opts, :valign, :top)
    margin_x = Keyword.get(opts, :margin_x, 0)
    margin_y = Keyword.get(opts, :margin_y, 0)

    text_bitmap = create_text(font, text)

    if Enum.empty?(text_bitmap.matrix) do
      Logger.debug("Empty text bitmap, returning target unchanged")
      target_bitmap  # Return target unchanged for empty text
    else
      # Calculate position based on alignment
      x = case alignment do
        :left -> margin_x
        :center -> div(target_bitmap.width - text_bitmap.width, 2)
        :right -> target_bitmap.width - text_bitmap.width - margin_x
      end

      # For bottom alignment, we use margin_y directly since y=0 is at the top
      y = case valign do
        :top -> target_bitmap.height - text_bitmap.height - margin_y
        :middle -> div(target_bitmap.height - text_bitmap.height, 2)
        :bottom -> margin_y
      end

      result = Bitmap.overlay(target_bitmap, text_bitmap, cursor_x: x, cursor_y: y)
      Logger.debug("Final bitmap after overlay: #{inspect(result)}")
      result
    end
  end

  # Private function that renders text without constraining to bitmap dimensions
  defp render_text_unconstrained(bitmap, _, _, []), do: bitmap

  defp render_text_unconstrained(bitmap, {cursor_x, cursor_y} = cursor, font, [character | tail]) do
    case Font.get_char_by_encoding(font, character) do
      nil ->
        # If character not found and no fallback, just advance cursor with a space
        if Map.has_key?(font.characters, 0) do
          render_text_unconstrained(bitmap, cursor, font, [0 | tail])
        else
          # Use a typical character width for spacing
          sample_char = font.characters |> Map.values() |> List.first()
          advance = if sample_char, do: Map.get(sample_char, :dwx0, 1), else: 1
          render_text_unconstrained(bitmap, {cursor_x + advance, cursor_y}, font, tail)
        end

      char ->
        kerning =
          case tail do
            [] -> 0
            _ ->
              pair = List.to_string([character, hd(tail)])
              Kerning.get_kerning(font, pair)
          end

        # Merge the character bitmap at the cursor position
        # The baseline alignment is handled by Bitmap.merge with preserve_baseline: true
        new_bitmap = Bitmap.merge(bitmap, char.bitmap,
          offset_x: cursor_x,
          offset_y: cursor_y,
          preserve_baseline: true
        )

        # Calculate next cursor position - stay on the baseline
        next_x = cursor_x + Map.get(char, :dwx0, Bitmap.width(char.bitmap) + 1) + kerning
        next_y = cursor_y  # Keep cursor at baseline

        render_text_unconstrained(new_bitmap, {next_x, next_y}, font, tail)
    end
  end

  # Keep the old render_text for backward compatibility
  def render_text(bitmap, cursor, font, text) do
    place_text(bitmap, font, text, align: :left, valign: :top,
               margin_x: elem(cursor, 0), margin_y: elem(cursor, 1))
  end
end
