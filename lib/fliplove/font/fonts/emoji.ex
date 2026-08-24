defmodule Fliplove.Font.Fonts.Emoji do
  @moduledoc """
  Shared emoji and pictographic glyphs for the built-in flipdot fonts.

  Emoji are square pictograms that do not meaningfully condense, so both the
  regular and the condensed flipdot font merge this common set into their
  character maps via `characters/0`. A font can still override any of these
  glyphs by defining the same codepoint in its own character map, since
  font-specific entries take precedence in the merge.

  Where an emoji has a classic text-symbol twin (e.g. ❤/♥, ⭐/★, ✓/✔),
  both codepoints are mapped to the same bitmap. Likewise all color heart
  variants share the standard heart bitmap, since the display only has one
  color anyway - except the white hearts, which render hollow.

  Emoji that only exist as ZWJ sequences (like ❤️‍🔥) have no codepoint of
  their own, so their glyphs live at Private Use Area codepoints and
  `zwj_sequences/0` tells the renderer which cluster maps to which glyph.
  """
  alias Fliplove.Bitmap
  import Bitmap

  # PUA codepoints for glyphs that Unicode only knows as ZWJ sequences
  # (the invader sprites occupy 0xE000-0xE006 in Fonts.Invaders)
  @heart_on_fire 0xE010

  # ❤ - the canonical filled heart; all color heart variants share it
  @heart_bitmap (defbitmap do
                   "       "
                   " XX XX "
                   "XXXXXXX"
                   "XXXXXXX"
                   " XXXXX "
                   "  XXX  "
                   "   X   "
                 end)

  # 🤍 - hollow heart for the white variants
  @hollow_heart_bitmap (defbitmap do
                          "       "
                          " XX XX "
                          "X  X  X"
                          "X     X"
                          " X   X "
                          "  X X  "
                          "   X   "
                        end)

  # ✓ - shared by the check mark variants
  @check_bitmap (defbitmap do
                   "     "
                   "    X"
                   "    X"
                   "   X "
                   "X X  "
                   " X   "
                   "     "
                 end)

  # ☂ - shared by umbrella and umbrella-with-rain
  @umbrella_bitmap (defbitmap do
                      "   X   "
                      " XXXXX "
                      "XXXXXXX"
                      "   X   "
                      "   X   "
                      "   X   "
                      "  XX   "
                    end)

  # ☃ - shared by the snowman variants
  @snowman_bitmap (defbitmap do
                     " XXX "
                     " X X "
                     " XXX "
                     "XXXXX"
                     "XX XX"
                     "XXXXX"
                     " XXX "
                   end)

  # ⌂ - shared by house symbol and house emoji
  @house_bitmap (defbitmap do
                   "   X   "
                   "  XXX  "
                   " XXXXX "
                   "XXXXXXX"
                   " XXXXX "
                   " XX XX "
                   " XX XX "
                 end)

  # ⌛ - shared by the hourglass variants
  @hourglass_bitmap (defbitmap do
                       "XXXXX"
                       " XXX "
                       "  X  "
                       "  X  "
                       " X X "
                       " XXX "
                       "XXXXX"
                     end)

  # 💀 - shared by skull and skull-and-crossbones
  @skull_bitmap (defbitmap do
                   " XXX "
                   "XXXXX"
                   "X X X"
                   "XXXXX"
                   " XXX "
                   " X X "
                   "     "
                 end)

  @characters %{
    # ♥
    0x2665 => %{name: "black-heart-suit", bitmap: @heart_bitmap},
    # ❤
    0x2764 => %{name: "heavy-black-heart", bitmap: @heart_bitmap},
    # 🧡
    0x1F9E1 => %{name: "orange-heart", bitmap: @heart_bitmap},
    # 💛
    0x1F49B => %{name: "yellow-heart", bitmap: @heart_bitmap},
    # 💚
    0x1F49A => %{name: "green-heart", bitmap: @heart_bitmap},
    # 💙
    0x1F499 => %{name: "blue-heart", bitmap: @heart_bitmap},
    # 💜
    0x1F49C => %{name: "purple-heart", bitmap: @heart_bitmap},
    # 🤎
    0x1F90E => %{name: "brown-heart", bitmap: @heart_bitmap},
    # 🖤
    0x1F5A4 => %{name: "black-heart", bitmap: @heart_bitmap},
    # 🩷
    0x1FA77 => %{name: "pink-heart", bitmap: @heart_bitmap},
    # 🩵
    0x1FA75 => %{name: "light-blue-heart", bitmap: @heart_bitmap},
    # 🩶
    0x1FA76 => %{name: "grey-heart", bitmap: @heart_bitmap},
    # 💗
    0x1F497 => %{name: "growing-heart", bitmap: @heart_bitmap},
    # 💓
    0x1F493 => %{name: "beating-heart", bitmap: @heart_bitmap},
    # 💖
    0x1F496 => %{name: "sparkling-heart", bitmap: @heart_bitmap},
    # 💘
    0x1F498 => %{name: "heart-with-arrow", bitmap: @heart_bitmap},
    # 💝
    0x1F49D => %{name: "heart-with-ribbon", bitmap: @heart_bitmap},
    # 💟
    0x1F49F => %{name: "heart-decoration", bitmap: @heart_bitmap},
    # 🤍
    0x1F90D => %{name: "white-heart", bitmap: @hollow_heart_bitmap},
    # ♡
    0x2661 => %{name: "white-heart-suit", bitmap: @hollow_heart_bitmap},
    # 💔
    0x1F494 => %{
      name: "broken-heart",
      bitmap:
        defbitmap do
          "       "
          " XX XX "
          "XX XXXX"
          "XXXX XX"
          " XX XX "
          "  X X  "
          "   X   "
        end
    },
    # ❤️‍🔥 (ZWJ sequence, see zwj_sequences/0)
    @heart_on_fire => %{
      name: "heart-on-fire",
      bitmap:
        defbitmap do
          " X X X "
          " XX XX "
          "XXXXXXX"
          "XXXXXXX"
          " XXXXX "
          "  XXX  "
          "   X   "
        end
    },
    # 💕
    0x1F495 => %{
      name: "two-hearts",
      bitmap:
        defbitmap do
          "X X  "
          "XXX  "
          " X   "
          "  X X"
          "  XXX"
          "   X "
          "     "
        end
    },
    # ❣
    0x2763 => %{
      name: "heavy-heart-exclamation",
      bitmap:
        defbitmap do
          " X X "
          "XXXXX"
          "XXXXX"
          " XXX "
          "  X  "
          "     "
          "  X  "
        end
    },
    # 😀
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
    # ☺
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
    # 🙂
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
    # ☹
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
    # 🙁
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
    # 😉
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
    # 😎
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
    # 😢
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
    # 💤
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
    # 👻
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
    # 👾
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
    # 🤖
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
    # 🔥
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
    # 💡
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
    # ❌
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
    # ❗
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
    # ❓
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
    # ♠
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
    # ♣
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
    # ♦
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
    # ★
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
    # ⭐
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
    # ☀
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
    # 🌙
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
    # ✓
    0x2713 => %{name: "check-mark", bitmap: @check_bitmap},
    # ✔
    0x2714 => %{name: "heavy-check-mark", bitmap: @check_bitmap},
    # ✅
    0x2705 => %{name: "white-heavy-check-mark", bitmap: @check_bitmap},
    # ♪
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
    # 🎵
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
    # ⚡
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
    },
    # ☁
    0x2601 => %{
      name: "cloud",
      bitmap:
        defbitmap do
          "       "
          "  XX   "
          " XXXX  "
          "XXXXXX "
          "XXXXXXX"
          " XXXXX "
          "       "
        end
    },
    # ☂
    0x2602 => %{name: "umbrella", bitmap: @umbrella_bitmap},
    # ☔
    0x2614 => %{name: "umbrella-with-rain-drops", bitmap: @umbrella_bitmap},
    # ☃
    0x2603 => %{name: "snowman", bitmap: @snowman_bitmap},
    # ⛄
    0x26C4 => %{name: "snowman-without-snow", bitmap: @snowman_bitmap},
    # 💧
    0x1F4A7 => %{
      name: "droplet",
      bitmap:
        defbitmap do
          "  X  "
          "  X  "
          " XXX "
          "XXXXX"
          "XXXXX"
          "XXXXX"
          " XXX "
        end
    },
    # ✉
    0x2709 => %{
      name: "envelope",
      bitmap:
        defbitmap do
          "       "
          "XXXXXXX"
          "XX   XX"
          "X X X X"
          "X  X  X"
          "XXXXXXX"
          "       "
        end
    },
    # ☕
    0x2615 => %{
      name: "hot-beverage",
      bitmap:
        defbitmap do
          " X X   "
          "       "
          "XXXXX  "
          "XXXXX X"
          "XXXXX X"
          "XXXXXX "
          " XXX   "
        end
    },
    # 🔔
    0x1F514 => %{
      name: "bell",
      bitmap:
        defbitmap do
          "  X  "
          " XXX "
          " XXX "
          " XXX "
          "XXXXX"
          "     "
          "  X  "
        end
    },
    # 🔒
    0x1F512 => %{
      name: "locked",
      bitmap:
        defbitmap do
          " XXX "
          "X   X"
          "X   X"
          "XXXXX"
          "XXXXX"
          "XX XX"
          "XXXXX"
        end
    },
    # 🔓
    0x1F513 => %{
      name: "unlocked",
      bitmap:
        defbitmap do
          " XXX "
          "X   X"
          "X    "
          "XXXXX"
          "XXXXX"
          "XX XX"
          "XXXXX"
        end
    },
    # 🔑
    0x1F511 => %{
      name: "key",
      bitmap:
        defbitmap do
          "       "
          "       "
          " XX    "
          "X  XXXX"
          " XX X X"
          "       "
          "       "
        end
    },
    # ⌂
    0x2302 => %{name: "house-symbol", bitmap: @house_bitmap},
    # 🏠
    0x1F3E0 => %{name: "house", bitmap: @house_bitmap},
    # ⌛
    0x231B => %{name: "hourglass-done", bitmap: @hourglass_bitmap},
    # ⏳
    0x23F3 => %{name: "hourglass-not-done", bitmap: @hourglass_bitmap},
    # 🚀
    0x1F680 => %{
      name: "rocket",
      bitmap:
        defbitmap do
          "  X  "
          " XXX "
          " XXX "
          " XXX "
          "XXXXX"
          " X X "
          "  X  "
        end
    },
    # ⚠
    0x26A0 => %{
      name: "warning",
      bitmap:
        defbitmap do
          "   X   "
          "  XXX  "
          "  X X  "
          " XX XX "
          " XXXXX "
          "XXX XXX"
          "XXXXXXX"
        end
    },
    # 💀
    0x1F480 => %{name: "skull", bitmap: @skull_bitmap},
    # ☠
    0x2620 => %{name: "skull-and-crossbones", bitmap: @skull_bitmap},
    # ☮
    0x262E => %{
      name: "peace-symbol",
      bitmap:
        defbitmap do
          "  XXX  "
          " X X X "
          "X  X  X"
          "X  X  X"
          "X XXX X"
          " X X X "
          "  XXX  "
        end
    },
    # ♫
    0x266B => %{
      name: "beamed-eighth-notes",
      bitmap:
        defbitmap do
          " XXXXX "
          " XXXXX "
          " X   X "
          " X   X "
          " X   X "
          "XX  XX "
          "XX  XX "
        end
    },
    # ✨
    0x2728 => %{
      name: "sparkles",
      bitmap:
        defbitmap do
          "  X   X"
          " XXX   "
          "XXXXX  "
          " XXX  X"
          "  X    "
          "     X "
          "       "
        end
    },
    # 😮
    0x1F62E => %{
      name: "face-with-open-mouth",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          " XXX "
          " XXX "
          "     "
        end
    },
    # 😛
    0x1F61B => %{
      name: "face-with-tongue",
      bitmap:
        defbitmap do
          "     "
          "XX XX"
          "XX XX"
          "     "
          "XXXXX"
          "  XX "
          "  XX "
        end
    },
    # ☑
    0x2611 => %{
      name: "ballot-box-with-check",
      bitmap:
        defbitmap do
          "XXXXXXX"
          "X     X"
          "X    XX"
          "XX  X X"
          "X XX  X"
          "X     X"
          "XXXXXXX"
        end
    }
  }

  # Grapheme clusters joined with U+200D that render as a single glyph. Keys
  # are the cluster's codepoints with variation selectors and joiners
  # stripped, exactly as the renderer normalizes them.
  @zwj_sequences %{
    # ❤️‍🔥
    [0x2764, 0x1F525] => @heart_on_fire
  }

  @doc """
  Returns the shared emoji character map, ready to be merged into a font's
  character map.
  """
  def characters, do: @characters

  @doc """
  Returns the map of known ZWJ sequences to the Private Use Area codepoint
  of their glyph. The renderer consults this to render sequences like ❤️‍🔥
  as a single glyph in fonts that provide it.
  """
  def zwj_sequences, do: @zwj_sequences
end
