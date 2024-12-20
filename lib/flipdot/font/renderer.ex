defmodule Flipdot.Font.Renderer do
  alias Flipdot.Font.Kerning
  require Logger

  @type alignment :: :left | :center | :right
  @type vertical_alignment :: :top | :middle | :bottom

  @doc """
  Renders text into a new bitmap that is exactly the size needed.
  Returns a bitmap sized to fit the rendered text. Returns an empty 0x0 bitmap for empty text.
  """
  def create_text(font, text) when is_binary(text) do
    Logger.debug("Creating text bitmap for: #{text}")
    create_text(font, String.to_charlist(text))
  end

  def create_text(_font, []), do: Bitmap.new(0, 0)

  def create_text(font, text) when is_list(text) do
    Logger.debug("Creating text bitmap with font: #{inspect(font)}")
    Logger.debug("Text to render: #{inspect(text)}")

    # Start rendering at {0,0} and let it grow
    bitmap = render_text_unconstrained(Bitmap.new(0, 0), {0, 0}, font, text)
    Logger.debug("Initial bitmap after rendering: #{inspect(bitmap)}")

    if Enum.empty?(bitmap.matrix) do
      Logger.debug("Empty bitmap matrix, returning empty bitmap")
      bitmap  # Return empty bitmap as is
    else
      # Get the actual bounds of the rendered text
      {min_x, min_y, max_x, max_y} = Bitmap.bbox(bitmap)
      Logger.debug("Bitmap bounds: min_x=#{min_x}, min_y=#{min_y}, max_x=#{max_x}, max_y=#{max_y}")

      # Normalize the bitmap while preserving baseline information
      result = Bitmap.normalize(bitmap)
      Logger.debug("Final bitmap: #{inspect(result)}")
      result
    end
  end

  @doc """
  Places text onto an existing bitmap with specified alignment.
  """
  def place_text(target_bitmap, font, text, opts \\ []) do
    Logger.debug("Placing text: #{text} with options: #{inspect(opts)}")
    alignment = Keyword.get(opts, :align, :left)
    valign = Keyword.get(opts, :valign, :top)
    margin_x = Keyword.get(opts, :margin_x, 0)
    margin_y = Keyword.get(opts, :margin_y, 0)

    text_bitmap = create_text(font, text)
    Logger.debug("Created text bitmap: #{inspect(text_bitmap)}")

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

      y = case valign do
        :top -> margin_y
        :middle -> div(target_bitmap.height - text_bitmap.height, 2)
        :bottom -> target_bitmap.height - text_bitmap.height - margin_y
      end

      Logger.debug("Placing text at position x=#{x}, y=#{y}")
      result = Bitmap.overlay(target_bitmap, text_bitmap, cursor_x: x, cursor_y: y)
      Logger.debug("Final bitmap after overlay: #{inspect(result)}")
      result
    end
  end

  # Private function that renders text without constraining to bitmap dimensions
  defp render_text_unconstrained(bitmap, _, _, []), do: bitmap

  defp render_text_unconstrained(bitmap, {cursor_x, cursor_y} = cursor, %{characters: chars} = font, [character | tail]) do
    Logger.debug("Rendering character: #{character} at cursor: {#{cursor_x}, #{cursor_y}}")
    Logger.debug("Available characters: #{inspect(Map.keys(chars))}")

    case Map.get(chars, character) do
      nil ->
        Logger.debug("Character #{character} not found in font")
        # If character not found and no fallback, just advance cursor with a space
        if Map.has_key?(chars, 0) do
          Logger.debug("Using fallback character 0")
          render_text_unconstrained(bitmap, cursor, font, [0 | tail])
        else
          Logger.debug("No fallback character available, using space")
          # Use a typical character width for spacing
          sample_char = chars |> Map.values() |> List.first()
          advance = if sample_char, do: Map.get(sample_char, :dwx0, 1), else: 1
          render_text_unconstrained(bitmap, {cursor_x + advance, cursor_y}, font, tail)
        end

      char ->
        Logger.debug("Found character data: #{inspect(char)}")
        kerning =
          case tail do
            [] -> 0
            _ ->
              pair = List.to_string([character, hd(tail)])
              Logger.debug("Checking kerning for pair: #{inspect(pair)}")
              Kerning.get_kerning(font, pair)
          end
        Logger.debug("Kerning value: #{kerning}")

        # Merge the character bitmap at the cursor position
        # The baseline alignment is handled by Bitmap.merge with preserve_baseline: true
        new_bitmap = Bitmap.merge(bitmap, char.bitmap,
          offset_x: cursor_x,
          offset_y: cursor_y,
          preserve_baseline: true
        )
        Logger.debug("Bitmap after adding character: #{inspect(new_bitmap)}")

        # Calculate next cursor position - stay on the baseline
        next_x = cursor_x + Map.get(char, :dwx0, Bitmap.width(char.bitmap) + 1) + kerning
        next_y = cursor_y  # Keep cursor at baseline
        Logger.debug("Next cursor position: {#{next_x}, #{next_y}}")

        render_text_unconstrained(new_bitmap, {next_x, next_y}, font, tail)
    end
  end

  # Keep the old render_text for backward compatibility
  def render_text(bitmap, cursor, font, text) do
    place_text(bitmap, font, text, align: :left, valign: :top,
               margin_x: elem(cursor, 0), margin_y: elem(cursor, 1))
  end
end
