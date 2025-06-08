defmodule Fliplove.Font.Parser do
  alias Fliplove.Bitmap
  import NimbleParsec
  alias Fliplove.Font
  require Logger

  @moduledoc """
  Parser for BDF font files. BDF files contain font definitions for low-resolution monochrome
  pixel fonts.
  """

  # Generic terms

  newline = ascii_char([?\n])

  whitespace = ascii_string([?\s, ?\v, ?\r, ?\t], min: 1)

  eol = ignore(eventually(newline) |> repeat(optional(whitespace) |> concat(newline)))

  def quoted_string_map(charlist) do
    List.to_string(charlist)
  end

  quoted_string =
    ignore(ascii_char([?"]))
    |> repeat(ascii_char([{:not, ?"}]))
    |> ignore(ascii_char([?"]))
    |> wrap()
    |> map(:quoted_string_map)

  hexdigit = ascii_char([?0..?9, ?A..?F, ?a..?f])
  hexbyte = hexdigit |> concat(hexdigit)

  # BDF specific terms

  bdf_font_name = ascii_string([0x20..0x7E], min: 1)
  bdf_name = ascii_string([0x21..0x7E], min: 1)

  defp number_map(members) do
    case members do
      [45, integer] -> -integer
      [integer] -> integer
    end
  end

  bdf_number =
    optional(ascii_char([?-]))
    |> integer(min: 1)
    |> wrap()
    |> map(:number_map)

  bdf_version = integer(min: 1) |> ignore(ascii_char([?.])) |> integer(min: 1)

  # BDF commands

  defp startfont_map([_, major, minor]) do
    %{version: Integer.to_string(major) <> "." <> Integer.to_string(minor)}
  end

  bdf_STARTFONT =
    string("STARTFONT")
    |> ignore(whitespace)
    |> concat(bdf_version)
    |> concat(eol)
    |> wrap()
    |> map(:startfont_map)

  bdf_COMMENT =
    string("COMMENT")
    |> ignore(whitespace)
    |> ignore(ascii_string([0x20..0x7E], min: 0))
    |> ignore(eol)
    |> replace(%{})

  bdf_ENDFONT = string("ENDFONT")

  defp font_map([_, name]) do
    %{name: name}
  end

  bdf_FONT =
    string("FONT")
    |> ignore(whitespace)
    |> concat(bdf_font_name)
    |> concat(eol)
    |> wrap()
    |> map(:font_map)

  defp size_map([_, size, xres, yres]) do
    %{size: size, xres: xres, yres: yres}
  end

  bdf_SIZE =
    string("SIZE")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:size_map)

  defp fontboundingbox_map([_, fbb_x, fbb_y, fbb_x_off, fbb_y_off]) do
    %{fbb_x: fbb_x, fbb_y: fbb_y, fbb_x_off: fbb_x_off, fbb_y_off: fbb_y_off}
  end

  bdf_FONTBOUNDINGBOX =
    string("FONTBOUNDINGBOX")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:fontboundingbox_map)

  defp dwidth_map([_, dwx0, dwy0]) do
    %{dwx0: dwx0, dwy0: dwy0}
  end

  bdf_DWIDTH =
    string("DWIDTH")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:dwidth_map)

  defp dwidth1_map([_, dwx1, dwy1]) do
    %{dwx1: dwx1, dwy1: dwy1}
  end

  bdf_DWIDTH1 =
    string("DWIDTH1")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:dwidth1_map)

  defp swidth_map([_, swx0, swy0]) do
    %{swx0: swx0, swy0: swy0}
  end

  bdf_SWIDTH =
    string("SWIDTH")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:swidth_map)

  defp swidth1_map([_, swx1, swy1]) do
    %{swx0: swx1, swy1: swy1}
  end

  bdf_SWIDTH1 =
    string("SWIDTH1")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:swidth1_map)

  # Support for additional BDF properties that might be encountered
  defp metricsset_map([_, direction]) do
    %{metricsset: direction}
  end

  bdf_METRICSSET =
    string("METRICSSET")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:metricsset_map)

  defp fix_it([first_char | [rest]]) do
    <<first_char>> <> rest
  end

  bdf_property_identifier =
    ascii_char([?a..?z, ?A..?Z, ?_])
    |> ascii_string([?a..?z, ?A..?Z, ?_, ?0..?9], min: 1)
    |> reduce({:fix_it, []})

  def property_map([cmd | [args]]) do
    %{(String.downcase(cmd) |> String.to_atom()) => args}
  end

  bdf_property =
    bdf_property_identifier
    |> ignore(whitespace)
    |> choice([
      quoted_string,
      bdf_number
    ])
    |> concat(eol)
    |> reduce(:property_map)

  defp properties_map(properties) do
    %{properties: Enum.reduce(properties, %{}, fn map, acc -> Map.merge(acc, map) end)}
  end

  bdf_properties =
    repeat(bdf_property)
    |> reduce(:properties_map)

  bdf_STARTPROPERTIES =
    string("STARTPROPERTIES")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()

  bdf_ENDPROPERTIES =
    string("ENDPROPERTIES")
    |> concat(eol)

  bdf_property_section =
    ignore(bdf_STARTPROPERTIES)
    |> concat(bdf_properties)
    |> ignore(bdf_ENDPROPERTIES)
    |> map({Enum, :into, [%{}]})

  defp encoding_map([_, encoding]) do
    %{encoding: encoding}
  end

  bdf_ENCODING =
    string("ENCODING")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:encoding_map)

  defp vvector_map([_, vv_x_off, vv_y_off]) do
    %{vv_x_off: vv_x_off, vv_y_off: vv_y_off}
  end

  bdf_VVECTOR =
    string("VVECTOR")
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:vvector_map)

  defp bbox_map([_, bb_width, bb_height, bb_x_off, bb_y_off]) do
    %{bb_width: bb_width, bb_height: bb_height, bb_x_off: bb_x_off, bb_y_off: bb_y_off}
  end

  bdf_BBX =
    string("BBX")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()
    |> map(:bbox_map)

  defp startchar_map([_, name]) do
    %{name: name}
  end

  bdf_STARTCHAR =
    string("STARTCHAR")
    |> ignore(whitespace)
    |> concat(bdf_name)
    |> concat(eol)
    |> wrap()
    |> map(:startchar_map)

  bdf_ENDCHAR =
    string("ENDCHAR")
    |> concat(eol)

  bdf_BITMAP =
    string("BITMAP")
    |> concat(eol)

  @doc """
  Converts a hex string to binary string representation.
  Optimized for BDF bitmap parsing.

  ## Examples

      iex> Fliplove.Font.Parser.hex_to_bin(["F0"])
      "11110000"

      iex> Fliplove.Font.Parser.hex_to_bin(["A5"])
      "10100101"
  """
  def hex_to_bin([hexstring]) when is_list(hexstring) do
    # Convert charlist to string once
    hex_str = List.to_string(hexstring)
    hex_length = String.length(hex_str)

    # Use more efficient conversion
    case Integer.parse(hex_str, 16) do
      {int_val, ""} ->
        # Pad to correct bit width (4 bits per hex digit)
        int_val
        |> Integer.to_string(2)
        |> String.pad_leading(hex_length * 4, "0")

      _ ->
        # Return a special error marker instead of raising
        # This allows parsing to continue and we can handle the error later
        {:error, "Invalid hex string: #{hex_str}"}
    end
  end

  bdf_char_bitmap_line = times(hexbyte, min: 1) |> concat(eol) |> wrap() |> reduce({:hex_to_bin, []})

  bdf_char_bitmap_lines = repeat(bdf_char_bitmap_line) |> wrap()

  defp bitmap_map([_, lines]) do
    %{bitmap_lines: lines}
  end

  bdf_char_bitmap =
    bdf_BITMAP
    |> concat(bdf_char_bitmap_lines)
    |> wrap()
    |> map(:bitmap_map)

  bdf_char =
    repeat(
      choice([
        bdf_ENCODING,
        bdf_DWIDTH,
        bdf_DWIDTH1,
        bdf_SWIDTH,
        bdf_SWIDTH1,
        bdf_VVECTOR,
        bdf_BBX,
        bdf_METRICSSET
      ])
    )
    |> concat(bdf_char_bitmap)

  defp char_map([startchar_map | char_properties]) do
    # Flatten the structure: startchar_map + list of char properties
    all_properties = [startchar_map | List.flatten(char_properties)]

    # First merge all properties
    char = Enum.reduce(all_properties, %{}, fn map, acc -> Map.merge(map, acc) end)

    # Validate required character fields - raise exceptions that will be caught by parse_font/1
    unless Map.has_key?(char, :encoding) do
      throw({:validation_error, "Character missing required ENCODING field"})
    end

    unless Map.has_key?(char, :name) do
      throw({:validation_error, "Character missing required name field"})
    end

    # Create bitmap if we have the required data
    char =
      if Map.has_key?(char, :bitmap_lines) and Map.has_key?(char, :bb_x_off) and Map.has_key?(char, :bb_y_off) do
        # Check if any bitmap lines contain error markers
        has_errors =
          Enum.any?(char.bitmap_lines, fn line ->
            is_tuple(line) and elem(line, 0) == :error
          end)

        if has_errors do
          error_lines =
            Enum.filter(char.bitmap_lines, fn line ->
              is_tuple(line) and elem(line, 0) == :error
            end)

          error_messages = Enum.map(error_lines, fn {:error, msg} -> msg end)

          # Store warning information in the character for later extraction
          char
          |> Map.put(:_parsing_warnings, [
            %{
              type: :invalid_bitmap,
              message: "Invalid hex data: #{Enum.join(error_messages, ", ")}",
              data: error_lines
            }
          ])
          |> Map.drop([:bitmap_lines])
        else
          try do
            bitmap =
              Bitmap.from_lines_of_text(
                char.bitmap_lines,
                baseline_x: char.bb_x_off,
                baseline_y: char.bb_y_off
              )

            # Remove bb_x_off and bb_y_off from char map since they're now in the bitmap
            char
            |> Map.drop([:bb_x_off, :bb_y_off, :bitmap_lines])
            |> Map.put(:bitmap, bitmap)
          rescue
            e ->
              # Store warning information in the character for later extraction
              char
              |> Map.put(:_parsing_warnings, [
                %{
                  type: :bitmap_creation_failed,
                  message: "Failed to create bitmap: #{Exception.message(e)}"
                }
              ])
              |> Map.drop([:bb_x_off, :bb_y_off, :bitmap_lines])
          end
        end
      else
        # Store warning information in the character for later extraction
        char
        |> Map.put(:_parsing_warnings, [
          %{
            type: :missing_bitmap_data,
            message: "Character missing bitmap data or bounding box information"
          }
        ])
      end

    char
  end

  bdf_char_section =
    bdf_STARTCHAR
    |> concat(bdf_char)
    |> ignore(bdf_ENDCHAR)
    |> wrap()
    |> map(:char_map)

  bdf_CHARS =
    string("CHARS")
    |> ignore(whitespace)
    |> concat(bdf_number)
    |> concat(eol)
    |> wrap()

  # convert a list of maps into a common map with each submap retrieving it's key from the "name:" value

  defp characters_map(char_maps) do
    Enum.reduce(char_maps, %{}, fn char_map, acc ->
      # Store the encoding value
      encoding = char_map.encoding
      # Now remove it from the char_map
      char_map = Map.drop(char_map, [:encoding])
      # Use the stored encoding as key
      Map.put(acc, encoding, char_map)
    end)
  end

  bdf_characters =
    repeat(bdf_char_section)
    |> wrap()
    |> map(:characters_map)

  # ignore number of characters advertised, just parse what is there

  defp characters_section_map(characters) do
    %{characters: characters}
  end

  bdf_characters_section =
    ignore(bdf_CHARS)
    |> concat(bdf_characters)
    |> map(:characters_section_map)

  defp bdf_map(maps) do
    Enum.reduce(maps, %Font{}, fn map, acc -> Map.merge(acc, map) end)
  end

  defcombinatorp(
    :bdf,
    bdf_STARTFONT
    |> repeat(
      choice([
        bdf_COMMENT,
        bdf_FONT,
        bdf_SIZE,
        bdf_FONTBOUNDINGBOX,
        bdf_DWIDTH,
        bdf_DWIDTH1,
        bdf_SWIDTH,
        bdf_SWIDTH1,
        bdf_METRICSSET,
        bdf_property_section
      ])
    )
    |> concat(bdf_characters_section)
    |> ignore(bdf_ENDFONT)
    |> optional(eol)
    |> wrap()
    |> map(:bdf_map)
  )

  defparsec(:parse_bdf, parsec(:bdf))

  def parse_font(path) when is_binary(path) do
    unless File.exists?(path) do
      raise File.Error, reason: :enoent, action: "open", path: path
    end

    try do
      content = File.read!(path)

      case parse_bdf(content) do
        {:ok, [font], _, _, _, _} ->
          validate_font!(font, path)
          font

        {:error, reason, remaining, _context, _line, _column} ->
          raise ArgumentError, """
          Failed to parse BDF font file: #{path}
          Error: #{reason}
          Remaining content: #{String.slice(remaining, 0, 100)}#{if String.length(remaining) > 100, do: "...", else: ""}
          """

        other ->
          raise ArgumentError, "Unexpected parse result for #{path}: #{inspect(other)}"
      end
    rescue
      File.Error ->
        reraise File.Error, __STACKTRACE__

      ArgumentError ->
        reraise ArgumentError, __STACKTRACE__

      e ->
        Logger.error("Failed to parse font file #{path}: #{inspect(e)}")
        raise ArgumentError, "Failed to parse BDF font file #{path}: #{Exception.message(e)}"
    catch
      {:validation_error, message} ->
        raise ArgumentError, message
    end
  end

  # Validates that the parsed font has required fields
  defp validate_font!(font, path) do
    unless font.name && is_binary(font.name) do
      raise ArgumentError, "Font file #{path} is missing required FONT name"
    end

    unless font.characters && is_map(font.characters) do
      raise ArgumentError, "Font file #{path} has no valid characters"
    end

    if map_size(font.characters) == 0 do
      Logger.warning("Font file #{path} contains no characters")
    end

    :ok
  end
end
