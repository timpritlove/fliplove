defmodule BLMParser do
  import NimbleParsec
  alias Flipdot.Bitmap

  @moduledoc """
  Parser for Blinkenlights Movie (BLM) files. These are typically delivered
  in a monochrome 18x8 pixel matrix and have been used by the Blinkenlights
  art installation in Berlin (2001).
  """

  # Generic terms

  newline = ascii_char([?\n])

  whitespace = ascii_string([?\s, ?\v, ?\t, ?\r], min: 1)

  eol = ignore(eventually(newline) |> repeat(optional(whitespace) |> concat(newline)))

  # BLM specific terms

  defp number_map(members) do
    case members do
      [45, integer] -> -integer
      [integer] -> integer
    end
  end

  blm_number =
    integer(min: 1)
    |> wrap()
    |> map(:number_map)

  defp magic_map([width, height]) do
    {:blm, width: width, height: height}
  end

  blm_name = ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)

  blm_magic =
    ignore(string("# BlinkenLights Movie"))
    |> ignore(whitespace)
    |> concat(blm_number)
    |> ignore(string("x"))
    |> concat(blm_number)
    |> concat(eol)
    |> wrap()
    |> map(:magic_map)

  defp meta_map([key, value]) do
    {String.to_atom(key), List.to_string(value)}
  end

  blm_meta =
    ignore(ascii_char([?#]))
    |> ignore(whitespace)
    |> concat(blm_name)
    |> ignore(whitespace)
    |> ignore(ascii_char([?=]))
    |> ignore(whitespace)
    |> wrap(repeat(ascii_char([{:not, ?\n}])))
    |> ignore(eol)
    |> wrap()
    |> map(:meta_map)

  blm_comment =
    ignore(ascii_char([?#]))
    |> ignore(repeat(ascii_char([{:not, ?\n}])))
    |> ignore(eol)

  defp header_map(header) do
    {:header, header}
  end

  blm_header =
    repeat(
      choice([
        blm_meta,
        blm_comment
      ])
    )
    |> wrap()
    |> map(:header_map)

  defp frame_ms_map(ms) do
    {:ms, ms}
  end

  blm_frame_ms =
    ignore(ascii_char([?@]))
    |> concat(blm_number)
    |> concat(eol)
    |> map(:frame_ms_map)

  blm_pixels = ascii_char([?0..?1]) |> repeat(ascii_char([?0..?1]))

  defp matrix_map(lines) do
    {:matrix, Bitmap.from_lines_of_text(lines, on: ?1, off: ?0)}
  end

  blm_matrix =
    repeat(
      blm_pixels
      |> ignore(repeat(whitespace))
      |> ignore(newline)
      |> wrap()
    )
    |> wrap()
    |> map(:matrix_map)

  defp frame_map(frame) do
    {:frame, frame}
  end

  blm_frame =
    ignore(optional(optional(whitespace) |> concat(newline)))
    |> concat(blm_frame_ms)
    |> concat(blm_matrix)
    |> wrap()
    |> map(:frame_map)

  defp frames_map(frames) do
    {:frames, frames}
  end

  blm_frames =
    repeat(blm_frame)
    |> wrap()
    |> map(:frames_map)

  defcombinatorp(
    :blm,
    blm_magic
    |> concat(blm_header)
    |> concat(blm_frames)
  )

  defparsec(:parse_blm, parsec(:blm))
end
