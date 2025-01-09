defmodule Fliplove.Font.Renderer do
  alias Fliplove.Font
  alias Fliplove.Font.Kerning
  alias Fliplove.Bitmap
  require Logger

  @type alignment :: :left | :center | :right
  @type vertical_alignment :: :top | :middle | :bottom

  @doc """
  Renders text into a new bitmap that is exactly the size needed.
  Returns a bitmap sized to fit the rendered text. Returns an empty 0x0 bitmap for empty text.
  """
  def create_text(font, text) when is_binary(text) do
    # Logger.debug("Creating text bitmap for: #{text}")
    create_text(font, String.to_charlist(text))
  end

  def create_text(_font, []), do: Bitmap.new(0, 0)

  def create_text(font, text) when is_list(text) do
    # Logger.debug("Creating text bitmap with font: #{inspect(font)}")
    # Logger.debug("Text to render: #{inspect(text)}")

    bitmap = render_text_unconstrained(Bitmap.new(0, 0), {0, 0}, font, text)
    # Logger.debug("Text bitmap before normalization: #{inspect(bitmap)}")

    normalized = Bitmap.normalize(bitmap)
    # Logger.debug("Text bitmap after normalization: #{inspect(normalized)}")
    normalized
  end

  @doc """
  Places text onto an existing bitmap with specified alignment.
  """
  def place_text(target_bitmap, font, text, opts \\ []) do
    # Logger.debug("Placing text: #{inspect(text)} with options: #{inspect(opts)}")
    alignment = Keyword.get(opts, :align, :left)
    valign = Keyword.get(opts, :valign, :top)
    margin_x = Keyword.get(opts, :margin_x, 0)
    margin_y = Keyword.get(opts, :margin_y, 0)

    text_bitmap = create_text(font, text)
    # Logger.debug("Created text bitmap: #{inspect(text_bitmap)}")

    # Logger.debug(
    #   "Text bitmap dimensions: #{text_bitmap.width}x#{text_bitmap.height}, baseline_y: #{text_bitmap.baseline_y}"
    # )

    if Enum.empty?(text_bitmap.matrix) do
      Logger.debug("Empty text bitmap, returning target unchanged")
      # Return target unchanged for empty text
      target_bitmap
    else
      # Calculate position based on alignment
      x =
        case alignment do
          :left -> margin_x
          :center -> div(target_bitmap.width - text_bitmap.width, 2)
          :right -> target_bitmap.width - text_bitmap.width - margin_x
        end

      # Calculate y position - note that higher y values are at the top
      y =
        case valign do
          :top -> target_bitmap.height - text_bitmap.height - margin_y
          :middle -> div(target_bitmap.height - text_bitmap.height, 2)
          :bottom -> margin_y
        end

      # Logger.debug("Placing text at position x=#{x}, y=#{y}")

      # Logger.debug(
      #   "Target bitmap dimensions: #{target_bitmap.width}x#{target_bitmap.height}, baseline_y: #{target_bitmap.baseline_y}"
      # )

      result = Bitmap.overlay(target_bitmap, text_bitmap, cursor_x: x, cursor_y: y)
      # Logger.debug("Final bitmap after overlay: #{inspect(result)}")
      # Logger.debug("Final bitmap dimensions: #{result.width}x#{result.height}, baseline_y: #{result.baseline_y}")
      result
    end
  end

  # Private function that renders text without constraining to bitmap dimensions
  defp render_text_unconstrained(bitmap, _, _, []), do: bitmap

  defp render_text_unconstrained(bitmap, {cursor_x, cursor_y} = cursor, font, [character | tail]) do
    # Logger.debug("Rendering character: #{inspect(character)} at cursor: {#{cursor_x}, #{cursor_y}}")

    case Font.get_char_by_encoding(font, character) do
      nil ->
        # Logger.debug("Character #{character} not found in font")
        # If character not found and no fallback, just advance cursor with a space
        if Map.has_key?(font.characters, 0) do
          # Logger.debug("Using fallback character 0")
          render_text_unconstrained(bitmap, cursor, font, [0 | tail])
        else
          # Logger.debug("No fallback character available, using space")
          # Use a typical character width for spacing
          sample_char = font.characters |> Map.values() |> List.first()
          advance = if sample_char, do: Map.get(sample_char, :dwx0, 1), else: 1
          # Logger.debug("Using advance width: #{advance}")
          render_text_unconstrained(bitmap, {cursor_x + advance, cursor_y}, font, tail)
        end

      char ->
        # Logger.debug("Found character data: #{inspect(char)}")
        # Logger.debug("Character bitmap: #{inspect(char.bitmap)}")

        kerning =
          case tail do
            [] ->
              0

            _ ->
              # Logger.debug("Checking kerning for pair: #{inspect([character, hd(tail)])}")
              k = Kerning.get_kerning(font, [character, hd(tail)])
              # Logger.debug("Kerning value: #{k}")
              k
          end

        # Merge the character bitmap at the cursor position
        # The baseline alignment is handled by Bitmap.merge with preserve_baseline: true
        # Logger.debug("Merging character at cursor_x: #{cursor_x}, cursor_y: #{cursor_y}")
        # Logger.debug("Current bitmap baseline_y: #{bitmap.baseline_y}")
        # Logger.debug("Character bitmap baseline_y: #{char.bitmap.baseline_y}")

        new_bitmap =
          Bitmap.merge(bitmap, char.bitmap,
            offset_x: cursor_x,
            offset_y: cursor_y,
            preserve_baseline: true
          )

        # Logger.debug("Bitmap after adding character: #{inspect(new_bitmap)}")
        # Logger.debug("New bitmap baseline_y: #{new_bitmap.baseline_y}")

        # Calculate next cursor position - stay on the baseline
        next_x = cursor_x + Map.get(char, :dwx0, Bitmap.width(char.bitmap) + 1) + kerning
        # Keep cursor at baseline
        next_y = cursor_y
        # Logger.debug("Next cursor position: {#{next_x}, #{next_y}}")

        render_text_unconstrained(new_bitmap, {next_x, next_y}, font, tail)
    end
  end

  # Keep the old render_text for backward compatibility
  def render_text(bitmap, cursor, font, text) do
    place_text(bitmap, font, text, align: :left, valign: :top, margin_x: elem(cursor, 0), margin_y: elem(cursor, 1))
  end
end
