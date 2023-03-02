defmodule FontParser do
  import NimbleParsec

  @moduledoc """
  Parser for BDF font files. BDF files contain font definitions for low-resolution monochrome
  pixel fonts.
  """

  # Generic terms

  newline = ascii_char([?\n])

  whitespace = ascii_string([?\s, ?\v, ?\t], min: 1)

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

  bdf_name = ascii_string([?a..?z, ?A..?Z, ?-, ?+, ?0..?9], min: 1)

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
    |> concat(quoted_string)
    |> concat(eol)
    |> wrap()

  bdf_ENDFONT = string("ENDFONT")

  defp font_map([_, name]) do
    %{name: name}
  end

  bdf_FONT =
    string("FONT")
    |> ignore(whitespace)
    |> concat(bdf_name)
    |> concat(eol)
    |> wrap()
    |> map(:font_map)

  defp size_map([_, point_size, xres, yres]) do
    %{point_size: point_size, xres: xres, yres: yres}
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

  def hex_to_bin([hexstring]) do
    hexstring
    |> List.to_string()
    |> String.to_integer(16)
    |> Integer.to_string(2)
    |> String.pad_leading(Enum.count(hexstring) * 4, "0")
  end

  bdf_char_bitmap_line =
    times(hexbyte, min: 1) |> concat(eol) |> wrap() |> reduce({:hex_to_bin, []})

  bdf_char_bitmap_lines = repeat(bdf_char_bitmap_line) |> wrap()

  defp bitmap_map([_, lines]) do
    %{bitmap: Bitmap.from_lines_of_text(lines, on: ?1, off: ?0)}
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
        bdf_BBX
      ])
    )
    |> concat(bdf_char_bitmap)

  defp char_map(properties) do
    Enum.reduce(properties, %{}, fn map, acc -> Map.merge(map, acc) end)
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
      # filtered_char_map = Enum.reject(char_map, fn {key, _value} -> key == :encoding end)
      Map.put(acc, char_map[:encoding], char_map)
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
    Enum.reduce(maps, %{}, fn map, acc -> Map.merge(acc, map) end)
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
end
