defmodule Fliplove.Font.Kerning do
  @moduledoc """
  Font kerning data and utilities for improved text spacing.

  This module provides kerning information to adjust spacing between specific
  character pairs for better typography. Kerning helps create more visually
  pleasing text by reducing or increasing space between certain letter combinations.

  ## Features
  - Character pair kerning data for various fonts
  - Kerning value lookup by font name and character pairs
  - Fallback to zero kerning for unknown pairs

  ## Example
      kerning = Fliplove.Font.Kerning.get_kerning("Helvetica-Bold", "We")
      # Returns -1 to bring W and e closer together
  """
  alias Fliplove.Bitmap
  alias Fliplove.Font

  @kerning %{
    "-Adobe-Helvetica-Bold-O-Normal--17-120-100-100-P-92-ISO8859-1" => %{
      17 => %{
        "We" => -1,
        "lu" => -1,
        "le" => -1,
        "nu" => -1,
        "ep" => -1,
        "es" => -1,
        "do" => -1,
        "ol" => -1,
        "ox" => -1,
        "sh" => -1,
        "ju" => -1,
        "br" => -1,
        "th" => -1,
        "qu" => -1,
        "tg" => -1,
        "st" => -1,
        "lt" => -1,
        "ui" => -1,
        "wn" => -1,
        "ov" => -1,
        "ps" => -1,
        "zi" => -1,
        "er" => -1,
        "Li" => -1,
        "li" => -1,
        "in" => -1,
        "ot" => -1
      }
    },
    "-Adobe-Helvetica-Medium-O-Normal--14-100-100-100-P-78-ISO8859-1" => %{
      14 => %{
        "Li" => -1,
        "ic" => -1,
        "es" => -1,
        "ht" => -1,
        "al" => -1
      }
    },
    "space-invaders" => %{
      7 => %{}
    },
    "flipdot" => %{
      7 => %{
        "lt" => -1,
        "Fa" => -1,
        "Fe" => -1,
        "Fo" => -1,
        "Fu" => -1,
        "Fr" => -1,
        "Fy" => -1,
        "Ta" => -1,
        "Te" => -1,
        "To" => -1,
        "Tu" => -1,
        "Tr" => -1,
        "Ty" => -1
      }
    },
    "flipdot_condensed" => %{
      7 => %{
        "Fa" => -1,
        "Fe" => -1,
        "Fo" => -1,
        "Fu" => -1,
        "Fr" => -1,
        "Fy" => -1,
        "Ta" => -1,
        "Te" => -1,
        "To" => -1,
        "Tu" => -1,
        "Tr" => -1,
        "Ty" => -1
      }
    }
  }

  def get_kerning(font, pair) do
    case @kerning[font.name][font.properties.pixel_size][List.to_string(pair)] do
      nil -> 0
      kerning -> kerning
    end
  end

  @doc """
  Calculates kerning value by analyzing the actual character bitmaps.
  Returns how many pixels the second character can be shifted left towards the first character.
  A negative value means the characters can overlap, while 0 means no kerning.
  Returns 0 if either character is empty (has no pixels set to 1).
  """
  def get_auto_kerning(font, [char1, char2] = _pair) do
    # Get character bitmaps
    bitmap1 = Font.get_char_by_encoding(font, char1).bitmap
    bitmap2 = Font.get_char_by_encoding(font, char2).bitmap

    # Return 0 if either bitmap has no pixels set to 1
    if not has_any_pixels?(bitmap1) or not has_any_pixels?(bitmap2) do
      0
    else
      # Get dimensions
      {width1, height1} = Bitmap.dimensions(bitmap1)
      {width2, height2} = Bitmap.dimensions(bitmap2)
      max_height = max(height1, height2)

      # For each possible overlap position, check if any pixels get too close
      # Maximum possible overlap to check
      max_overlap = width1

      # Try each overlap amount from most aggressive to none
      Enum.reduce_while(1..max_overlap, 0, fn overlap, _acc ->
        # Check if any pixels get too close at this overlap amount
        too_close =
          Enum.any?(0..(max_height - 1), fn y ->
            # For each row, check if any pixels in bitmap1 are too close to pixels in bitmap2
            Enum.any?((width1 - overlap)..(width1 - 1), fn x1 ->
              pixel1 = Bitmap.get_pixel(bitmap1, {x1, y})
              # Only check proximity if this pixel is on
              if pixel1 == 1 do
                # Check surrounding pixels in bitmap2
                # Corresponding x in bitmap2
                x2 = x1 - (width1 - overlap)

                Enum.any?(max(0, x2 - 1)..min(width2 - 1, x2 + 1), fn check_x2 ->
                  Enum.any?(max(0, y - 1)..min(max_height - 1, y + 1), fn check_y2 ->
                    Bitmap.get_pixel(bitmap2, {check_x2, check_y2}) == 1
                  end)
                end)
              else
                false
              end
            end)
          end)

        if too_close do
          # Found pixels too close, use previous overlap amount
          {:halt, -(overlap - 1)}
        else
          # This overlap amount works, try more
          {:cont, -overlap}
        end
      end)
    end
  end

  # Helper function to check if a bitmap has any pixels set to 1
  defp has_any_pixels?(bitmap) do
    Enum.any?(bitmap.matrix, fn {_pos, value} -> value == 1 end)
  end
end
