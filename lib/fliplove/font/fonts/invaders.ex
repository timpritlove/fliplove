defmodule Fliplove.Font.Fonts.Invaders do
  @moduledoc """
  Space invader sprite glyphs at Private Use Area codepoints.

  These sprites are not covered by Unicode, so they live in the Basic
  Multilingual Plane's Private Use Area (U+E000-U+F8FF), which Unicode
  reserves for exactly this kind of self-defined character. They previously
  hijacked the codepoints of the accented letters á, à, í, ì, ó, ò and å;
  those codepoints now render as real letters again.

  All built-in flipdot fonts merge this set into their character maps, so an
  invader animation renders the same regardless of the selected font. Each
  invader type comes in two animation frames; alternate them to animate.

  Use the accessor functions to build strings without magic numbers:

      List.to_string([Invaders.crab_0()])
  """
  alias Fliplove.Bitmap
  import Bitmap

  @crab_0 0xE000
  @crab_1 0xE001
  @squid_0 0xE002
  @squid_1 0xE003
  @octopus_0 0xE004
  @octopus_1 0xE005
  @ufo 0xE006

  def crab_0, do: @crab_0
  def crab_1, do: @crab_1
  def squid_0, do: @squid_0
  def squid_1, do: @squid_1
  def octopus_0, do: @octopus_0
  def octopus_1, do: @octopus_1
  def ufo, do: @ufo

  @characters %{
    @crab_0 => %{
      name: "crab_invader_0",
      bitmap:
        defbitmap do
          "  X     X  "
          "   X   X   "
          "  XXXXXXX  "
          " XX XXX XX "
          "XXXXXXXXXXX"
          "X XXXXXXX X"
          "X X     X X"
          "   XX XX   "
        end
    },
    @crab_1 => %{
      name: "crab_invader_1",
      bitmap:
        defbitmap do
          "  X     X  "
          "X  X   X  X"
          "X XXXXXXX X"
          "XXX XXX XXX"
          "XXXXXXXXXXX"
          " XXXXXXXXX "
          "  X     X  "
          " X       X "
        end
    },
    @squid_0 => %{
      name: "squid_invader_0",
      bitmap:
        defbitmap do
          "   XX   "
          "  XXXX  "
          " XXXXXX "
          "XX XX XX"
          "XXXXXXXX"
          "  X  X  "
          " X XX X "
          "X X  X X"
        end
    },
    @squid_1 => %{
      name: "squid_invader_1",
      bitmap:
        defbitmap do
          "   XX   "
          "  XXXX  "
          " XXXXXX "
          "XX XX XX"
          "XXXXXXXX"
          " X XX X "
          "X      X"
          " X    X "
        end
    },
    @octopus_0 => %{
      name: "octopus_invader_0",
      bitmap:
        defbitmap do
          "    XXXX    "
          " XXXXXXXXXX "
          "XXXXXXXXXXXX"
          "XXX  XX  XXX"
          "XXXXXXXXXXXX"
          "   XX  XX   "
          "  XX XX XX  "
          "XX        XX"
        end
    },
    @octopus_1 => %{
      name: "octopus_invader_1",
      bitmap:
        defbitmap do
          "    XXXX    "
          " XXXXXXXXXX "
          "XXXXXXXXXXXX"
          "XXX  XX  XXX"
          "XXXXXXXXXXXX"
          "  XXX  XXX  "
          " XX  XX  XX "
          "  XX    XX  "
        end
    },
    @ufo => %{
      name: "invader_ufo",
      bitmap:
        defbitmap do
          "     XXXXXX     "
          "   XXXXXXXXXX   "
          "  XXXXXXXXXXXX  "
          " XX XX XX XX XX "
          "XXXXXXXXXXXXXXXX"
          "  XXX  XX   XXX "
          "   X         X  "
        end
    }
  }

  @doc """
  Returns the invader sprite character map, ready to be merged into a font's
  character map.
  """
  def characters, do: @characters
end
