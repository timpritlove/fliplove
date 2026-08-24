defmodule Fliplove.Font.Fonts.Emoji do
  @moduledoc """
  Shared emoji and pictographic glyphs for the built-in flipdot fonts.

  Emoji are square pictograms that do not meaningfully condense, so both the
  regular and the condensed flipdot font merge this common set into their
  character maps via `characters/0`. A font can still override any of these
  glyphs by defining the same codepoint in its own character map, since
  font-specific entries take precedence in the merge.

  Where an emoji has a classic text-symbol twin (e.g. ❤/♥, ⭐/★, ✓/✔),
  both codepoints are mapped to the same bitmap.
  """
  alias Fliplove.Bitmap
  import Bitmap

  @characters %{
    0x2665 => %{
      name: "black-heart-suit",
      bitmap:
        defbitmap do
          "       "
          " XX XX "
          "XXXXXXX"
          "XXXXXXX"
          " XXXXX "
          "  XXX  "
          "   X   "
        end
    },
    0x2764 => %{
      name: "heavy-black-heart",
      bitmap:
        defbitmap do
          "       "
          " XX XX "
          "XXXXXXX"
          "XXXXXXX"
          " XXXXX "
          "  XXX  "
          "   X   "
        end
    },
    0x1F600 => %{
      name: "grinning-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          "XXXXX"
          " XXX "
          "     "
        end
    },
    0x263A => %{
      name: "white-smiling-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          "X   X"
          " XXX "
          "     "
        end
    },
    0x1F642 => %{
      name: "slightly-smiling-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          "X   X"
          " XXX "
          "     "
        end
    },
    0x2639 => %{
      name: "white-frowning-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          " XXX "
          "X   X"
          "     "
        end
    },
    0x1F641 => %{
      name: "slightly-frowning-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          " XXX "
          "X   X"
          "     "
        end
    },
    0x1F609 => %{
      name: "winking-face",
      bitmap:
        defbitmap do
          "     "
          "   XX"
          "XX XX"
          "     "
          "X   X"
          " XXX "
          "     "
        end
    },
    0x1F60E => %{
      name: "smiling-face-with-sunglasses",
      bitmap:
        defbitmap do
          "     "
          "XXXXX"
          "XX XX"
          "     "
          "X   X"
          " XXX "
          "     "
        end
    },
    0x1F622 => %{
      name: "crying-face",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "X    "
          " XXX "
          "X   X"
          "     "
        end
    },
    0x1F4A4 => %{
      name: "sleeping-symbol",
      bitmap:
        defbitmap do
          "XXX  "
          " X   "
          "XXX  "
          "   XX"
          "   X "
          "   XX"
          "     "
        end
    },
    0x1F47B => %{
      name: "ghost",
      bitmap:
        defbitmap do
          " XXX "
          "XXXXX"
          "X X X"
          "XXXXX"
          "XXXXX"
          "XXXXX"
          "X X X"
        end
    },
    0x1F47E => %{
      name: "alien-monster",
      bitmap:
        defbitmap do
          "  X X  "
          " XXXXX "
          "XX X XX"
          "XXXXXXX"
          "X XXX X"
          "X     X"
          " X   X "
        end
    },
    0x1F916 => %{
      name: "robot-face",
      bitmap:
        defbitmap do
          "  X  "
          "XXXXX"
          "X X X"
          "XXXXX"
          "X   X"
          "XXXXX"
          "     "
        end
    },
    0x1F525 => %{
      name: "fire",
      bitmap:
        defbitmap do
          "   X "
          "  X  "
          "  XX "
          " XXX "
          "XXXXX"
          "XXXXX"
          " XXX "
        end
    },
    0x1F4A1 => %{
      name: "electric-light-bulb",
      bitmap:
        defbitmap do
          " XXX "
          "X   X"
          "X   X"
          " X X "
          " XXX "
          " XXX "
          "  X  "
        end
    },
    0x274C => %{
      name: "cross-mark",
      bitmap:
        defbitmap do
          "     "
          "X   X"
          " X X "
          "  X  "
          " X X "
          "X   X"
          "     "
        end
    },
    0x2757 => %{
      name: "heavy-exclamation-mark",
      bitmap:
        defbitmap do
          "XX"
          "XX"
          "XX"
          "XX"
          "XX"
          "  "
          "XX"
        end
    },
    0x2753 => %{
      name: "black-question-mark-ornament",
      bitmap:
        defbitmap do
          " XXX "
          "XX XX"
          "   XX"
          "  XX "
          "  XX "
          "     "
          "  XX "
        end
    },
    0x2660 => %{
      name: "black-spade-suit",
      bitmap:
        defbitmap do
          "  X  "
          " XXX "
          "XXXXX"
          "XXXXX"
          "XXXXX"
          "  X  "
          " XXX "
        end
    },
    0x2663 => %{
      name: "black-club-suit",
      bitmap:
        defbitmap do
          "  X  "
          " XXX "
          "  X  "
          "XX XX"
          "XXXXX"
          "  X  "
          " XXX "
        end
    },
    0x2666 => %{
      name: "black-diamond-suit",
      bitmap:
        defbitmap do
          "     "
          "  X  "
          " XXX "
          "XXXXX"
          " XXX "
          "  X  "
          "     "
        end
    },
    0x2605 => %{
      name: "black-star",
      bitmap:
        defbitmap do
          "   X   "
          "  XXX  "
          "XXXXXXX"
          " XXXXX "
          "  XXX  "
          " XX XX "
          "XX   XX"
        end
    },
    0x2B50 => %{
      name: "white-medium-star",
      bitmap:
        defbitmap do
          "   X   "
          "  XXX  "
          "XXXXXXX"
          " XXXXX "
          "  XXX  "
          " XX XX "
          "XX   XX"
        end
    },
    0x2600 => %{
      name: "black-sun-with-rays",
      bitmap:
        defbitmap do
          "   X   "
          " X   X "
          "  XXX  "
          "X XXX X"
          "  XXX  "
          " X   X "
          "   X   "
        end
    },
    0x1F319 => %{
      name: "crescent-moon",
      bitmap:
        defbitmap do
          "  XX "
          " XX  "
          "XX   "
          "XX   "
          "XX   "
          " XX  "
          "  XX "
        end
    },
    0x2713 => %{
      name: "check-mark",
      bitmap:
        defbitmap do
          "     "
          "    X"
          "    X"
          "   X "
          "X X  "
          " X   "
          "     "
        end
    },
    0x2714 => %{
      name: "heavy-check-mark",
      bitmap:
        defbitmap do
          "     "
          "    X"
          "    X"
          "   X "
          "X X  "
          " X   "
          "     "
        end
    },
    0x266A => %{
      name: "eighth-note",
      bitmap:
        defbitmap do
          "  XX "
          "  X X"
          "  X X"
          "  X  "
          "  X  "
          "XXX  "
          "XXX  "
        end
    },
    0x1F3B5 => %{
      name: "musical-note",
      bitmap:
        defbitmap do
          "  XX "
          "  X X"
          "  X X"
          "  X  "
          "  X  "
          "XXX  "
          "XXX  "
        end
    },
    0x26A1 => %{
      name: "high-voltage",
      bitmap:
        defbitmap do
          "  XXX"
          " XXX "
          "XXXXX"
          "  XX "
          " XX  "
          "XX   "
          "X    "
        end
    }
  }

  @doc """
  Returns the shared emoji character map, ready to be merged into a font's
  character map.
  """
  def characters, do: @characters
end
