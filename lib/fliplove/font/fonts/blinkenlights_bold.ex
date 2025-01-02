defmodule Fliplove.Font.Fonts.BlinkenlightsBold do
  alias Fliplove.Bitmap
  import Bitmap
  alias Fliplove.Font

  @font %Font{
    name: "blinkenlights-bold",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Blinkenlights",
      foundry: "BBB",
      weight_name: "Bold",
      slant: "R",
      pixel_size: 7
    },
    characters: %{
      0 => %{
        name: "defaultchar",
        bitmap:
          defbitmap([
            "XXXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XXXXXX"
          ])
      },
      ?\s => %{
        name: "space",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?! => %{
        name: "exclamation mark",
        bitmap:
          defbitmap([
            "XX",
            "XX",
            "XX",
            "XX",
            "XX",
            "  ",
            "XX"
          ])
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap([
            "XX XX",
            "XX XX",
            "     ",
            "     ",
            "     ",
            "     ",
            "     "
          ])
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap([
            " XX XX ",
            " XX XX ",
            "XXXXXXX",
            " XX XX ",
            "XXXXXXX",
            " XX XX ",
            " XX XX "
          ])
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap([
            "   XX   ",
            "  XXXXXX",
            "XX XX   ",
            "  XXXX  ",
            "   XX XX",
            "XXXXXX  ",
            "   XX   "
          ])
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "   XX ",
            "  XX  ",
            " XX   ",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap([
            " XXXX   ",
            "XX  XX  ",
            "XX  XX  ",
            " XXXX   ",
            "XX XX XX",
            "XX  XX  ",
            " XXX XX "
          ])
      },
      ?' => %{
        name: "apostrophe",
        bitmap:
          defbitmap([
            "XX",
            "XX",
            "  ",
            "  ",
            "  ",
            "  ",
            "  "
          ])
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap([
            "  XX",
            " XX ",
            "XX  ",
            "XX  ",
            "XX  ",
            " XX ",
            "  XX"
          ])
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap([
            "XX  ",
            " XX ",
            "  XX",
            "  XX",
            "  XX",
            " XX ",
            "XX  "
          ])
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap([
            "       ",
            "XX X XX",
            " XXXXX ",
            "XXXXXXX",
            " XXXXX ",
            "XX X XX",
            "       "
          ])
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap([
            "      ",
            "  XX  ",
            "  XX  ",
            "XXXXXX",
            "  XX  ",
            "  XX  ",
            "      "
          ])
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap(
            [
              " XX",
              "XX "
            ],
            baseline_y: -1
          )
      },
      ?- => %{
        name: "hyphen",
        bitmap:
          defbitmap([
            "XXXX",
            "    ",
            "    ",
            "    "
          ])
      },
      ?. => %{
        name: "period",
        bitmap:
          defbitmap([
            "XX"
          ])
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap([
            "    XX",
            "    XX",
            "   XX ",
            "  XX  ",
            " XX   ",
            "XX    ",
            "XX    "
          ])
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap([
            " XX ",
            "XXX ",
            " XX ",
            " XX ",
            " XX ",
            " XX ",
            "XXXX"
          ])
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "   XX ",
            "  XX  ",
            " XX   ",
            "XX    ",
            "XXXXXX"
          ])
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "    XX",
            "   XX ",
            "    XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap([
            "XX    ",
            "XX  XX",
            "XX  XX",
            "XXXXXX",
            "    XX",
            "    XX",
            "    XX"
          ])
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap([
            "XXXXXX",
            "XX    ",
            "XXXXX ",
            "    XX",
            "    XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX    ",
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap([
            "XXXXXX",
            "    XX",
            "   XX ",
            "  XX  ",
            "  XX  ",
            "  XX  ",
            "  XX  "
          ])
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            " XXXXX",
            "    XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap([
            "XX",
            "  ",
            "XX",
            "  ",
            "  "
          ])
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap([
            " XX",
            "   ",
            " XX",
            " XX",
            "XX "
          ])
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap([
            "     ",
            "  XX ",
            " XX  ",
            "XX   ",
            " XX  ",
            "  XX ",
            "     "
          ])
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap([
            "XXXXXX",
            "      ",
            "XXXXXX",
            "      ",
            "      "
          ])
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap([
            "     ",
            " XX  ",
            "  XX ",
            "   XX",
            "  XX ",
            " XX  ",
            "     "
          ])
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "   XX ",
            "  XX  ",
            "  XX  ",
            "      ",
            "  XX  "
          ])
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap([
            "  XXXXXXXX  ",
            " XX      XX ",
            "XX  XX X  XX",
            "XX XX XX  XX",
            "XX  XX XXXX ",
            " XX         ",
            "  XXXXXXX   "
          ])
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XXXXX "
          ])
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX    ",
            "XX    ",
            "XX    ",
            "XX    ",
            "XX    ",
            " XXXXX"
          ])
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XXXXX "
          ])
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap([
            "XXXXXX",
            "XX    ",
            "XX    ",
            "XXXX  ",
            "XX    ",
            "XX    ",
            "XXXXXX"
          ])
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap([
            "XXXXXX",
            "XX    ",
            "XX    ",
            "XXXX  ",
            "XX    ",
            "XX    ",
            "XX    "
          ])
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX    ",
            "XX XXX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap([
            "XXXX",
            " XX ",
            " XX ",
            " XX ",
            " XX ",
            " XX ",
            "XXXX"
          ])
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap([
            "    XX",
            "    XX",
            "    XX",
            "    XX",
            "    XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap([
            "XX   XX",
            "XX  XX ",
            "XX XX  ",
            "XXXX   ",
            "XX XX  ",
            "XX  XX ",
            "XX   XX"
          ])
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap([
            "XX    ",
            "XX    ",
            "XX    ",
            "XX    ",
            "XX    ",
            "XX    ",
            "XXXXXX"
          ])
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap([
            "XX   XX",
            "XXX XXX",
            "XXXXXXX",
            "XX X XX",
            "XX   XX",
            "XX   XX",
            "XX   XX"
          ])
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap([
            "XX   XX",
            "XXX  XX",
            "XXXX XX",
            "XX XXXX",
            "XX  XXX",
            "XX   XX",
            "XX   XX"
          ])
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XXXXX ",
            "XX    ",
            "XX    ",
            "XX    "
          ])
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX XX ",
            " XX XX"
          ])
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XXXXX ",
            "XX XX ",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX    ",
            " XXXX ",
            "    XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap([
            "XXXXXX",
            "  XX  ",
            "  XX  ",
            "  XX  ",
            "  XX  ",
            "  XX  ",
            "  XX  "
          ])
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "  XX  "
          ])
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap([
            "XX   XX",
            "XX   XX",
            "XX   XX",
            "XX   XX",
            "XX X XX",
            "XXX XXX",
            "XX   XX"
          ])
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "  XX  ",
            " XXXX ",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "  XX  ",
            "  XX  ",
            "  XX  "
          ])
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap([
            "XXXXXX",
            "    XX",
            "   XX ",
            "  XX  ",
            " XX   ",
            "XX    ",
            "XXXXXX"
          ])
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap([
            "XXXX",
            "XX  ",
            "XX  ",
            "XX  ",
            "XX  ",
            "XX  ",
            "XXXX"
          ])
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap([
            "XX    ",
            "XX    ",
            " XX   ",
            "  XX  ",
            "   XX ",
            "    XX",
            "    XX"
          ])
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap([
            "XXXX",
            "  XX",
            "  XX",
            "  XX",
            "  XX",
            "  XX",
            "XXXX"
          ])
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap([
            "  XX  ",
            " XXXX ",
            "XX  XX",
            "      ",
            "      ",
            "      ",
            "      "
          ])
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap([
            "XXXXX"
          ])
      },
      ?` => %{
        name: "apostrophe",
        bitmap:
          defbitmap([
            "XX ",
            " XX",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXXX"
          ])
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap([
            "XX    ",
            "XX    ",
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XXXXX "
          ])
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX    ",
            "XX    ",
            "XX    ",
            " XXXXX"
          ])
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap([
            "    XX",
            "    XX",
            " XXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXXX"
          ])
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX    ",
            " XXXXX"
          ])
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap([
            "  XXX",
            " XX  ",
            " XX  ",
            "XXXXX",
            " XX  ",
            " XX  ",
            " XX  "
          ])
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX  XX",
            " XXXXX",
            "    XX",
            "XXXXX "
          ])
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap([
            "XX    ",
            "XX    ",
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?i => %{
        name: "i",
        bitmap:
          defbitmap([
            "XX",
            "  ",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX"
          ])
      },
      ?j => %{
        name: "j",
        bitmap:
          defbitmap([
            "   XX",
            "     ",
            "   XX",
            "   XX",
            "   XX",
            "XX XX",
            " XXX "
          ])
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap([
            "XX    ",
            "XX XX ",
            "XXXX  ",
            "XXXX  ",
            "XXXX  ",
            "XX XX ",
            "XX  XX"
          ])
      },
      ?l => %{
        name: "l",
        bitmap:
          defbitmap([
            "XX",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX"
          ])
      },
      ?m => %{
        name: "m",
        bitmap:
          defbitmap([
            "XXX XXX ",
            "XX XX XX",
            "XX XX XX",
            "XX XX XX",
            "XX XX XX"
          ])
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap([
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap([
            "XXXXX ",
            "XX  XX",
            "XXXXX ",
            "XX    ",
            "XX    "
          ])
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX  XX",
            " XXXXX",
            "    XX",
            "    XX"
          ])
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap([
            " XXXX",
            "XX   ",
            "XX   ",
            "XX   ",
            "XX   "
          ])
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap([
            " XXXXX",
            "XX    ",
            " XXXX ",
            "    XX",
            "XXXXX "
          ])
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap([
            " XX ",
            " XX ",
            "XXXX",
            " XX ",
            " XX ",
            " XX ",
            " XX "
          ])
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "  XX  "
          ])
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap([
            "XX    XX",
            "XX    XX",
            "XX XX XX",
            "XX XX XX",
            " XX  XX "
          ])
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap([
            "XX  XX",
            " XXXX ",
            "  XX  ",
            " XXXX ",
            "XX  XX"
          ])
      },
      ?y => %{
        name: "y",
        bitmap:
          defbitmap([
            "XX  XX",
            "XX  XX",
            " XXXXX",
            "    XX",
            "XXXXX "
          ])
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap([
            "XXXXXX",
            "   XX ",
            "  XX  ",
            " XX   ",
            "XXXXXX"
          ])
      },
      ?{ => %{
        name: "left curly bracket",
        bitmap:
          defbitmap([
            "  XX",
            " XX ",
            " XX ",
            "XX  ",
            " XX ",
            " XX ",
            "  XX"
          ])
      },
      ?| => %{
        name: "vertical bar",
        bitmap:
          defbitmap([
            "XX",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX"
          ])
      },
      ?} => %{
        name: "right curly bracket",
        bitmap:
          defbitmap([
            "XX  ",
            " XX ",
            " XX ",
            "  XX",
            " XX ",
            " XX ",
            "XX  "
          ])
      },
      ?~ => %{
        name: "tilde",
        bitmap:
          defbitmap([
            " XX    ",
            "XX X XX",
            "    XX ",
            "       ",
            "       "
          ])
      },

      # ISO 8859-1 CHARACTERS

      160 => %{
        name: "no-break space",
        bitmap:
          defbitmap([
            "  ",
            "  ",
            "  ",
            "  ",
            "  ",
            "  ",
            "  "
          ])
      },
      ?¡ => %{
        name: "inverted exclamation mark",
        bitmap:
          defbitmap([
            "XX",
            "  ",
            "XX",
            "XX",
            "XX",
            "XX",
            "XX"
          ])
      },
      ?¢ => %{
        name: "cent sign",
        bitmap:
          defbitmap([
            "  XXXX",
            " XX   ",
            "XXXXX ",
            " XX   ",
            "  XXXX",
            "      "
          ])
      },
      ?£ => %{
        name: "pound sign",
        bitmap:
          defbitmap([
            "  XXXX",
            " XX   ",
            " XX   ",
            "XXXXX ",
            " XX   ",
            " XX   ",
            "XXXXXX"
          ])
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap([
            "      ",
            "XX  XX",
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX ",
            "XX  XX"
          ])
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap([
            "XX  XX",
            " XXXX ",
            "XXXXXX",
            "  XX  ",
            "XXXXXX",
            "  XX  ",
            "  XX  "
          ])
      },
      ?¦ => %{
        name: "broken bar",
        bitmap:
          defbitmap([
            "XX",
            "XX",
            "XX",
            "  ",
            "XX",
            "XX",
            "XX"
          ])
      },
      ?§ => %{
        name: "section sign",
        bitmap:
          defbitmap(
            [
              " XXX ",
              "X    ",
              " X   ",
              " XXX ",
              "X   X",
              " XXX ",
              "   X ",
              "    X",
              " XXX "
            ],
            baseline_y: -1
          )
      },
      ?ß => %{
        name: "sharp s",
        bitmap:
          defbitmap(
            [
              " XXXXX ",
              "XX   XX",
              "XX  XX ",
              "XX XX  ",
              "XX  XX ",
              "XX   XX",
              "XX XXX ",
              "XX     "
            ],
            baseline_y: -1
          )
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap([
            "      ",
            "XX  XX",
            "      ",
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?Á => %{
        name: "A with acute",
        bitmap:
          defbitmap([
            "   XX ",
            "  XX  ",
            "      ",
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?À => %{
        name: "A with grave",
        bitmap:
          defbitmap([
            " XX   ",
            "  XX  ",
            "      ",
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?Å => %{
        name: "A with ring",
        bitmap:
          defbitmap([
            " XXXX ",
            " XXXX ",
            "      ",
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?Ã => %{
        name: "A with tilde",
        bitmap:
          defbitmap([
            " XX XX",
            "XX XX ",
            "      ",
            " XXXX ",
            "XX  XX",
            "XXXXXX",
            "XX  XX",
            "XX  XX"
          ])
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            " XXXXX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXXX"
          ])
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            " XXXX ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            "XX  XX",
            " XXXX "
          ])
      },
      ?¨ => %{
        name: "diaresis",
        bitmap:
          defbitmap([
            "XX  XX",
            "      ",
            "      ",
            "      ",
            "      ",
            "      ",
            "      "
          ])
      },
      ?© => %{
        name: "copyright sign",
        bitmap:
          defbitmap(
            [
              " XXX ",
              "X   X",
              "  X  ",
              " X X ",
              " X   ",
              " X X ",
              "  X  ",
              "X   X",
              " XXX "
            ],
            baseline_y: -1
          )
      },
      ?€ => %{
        name: "euro sign",
        bitmap:
          defbitmap([
            "  XXX",
            " X   ",
            "XXXX ",
            " X   ",
            "XXXX ",
            " X   ",
            "  XXX"
          ])
      },
      ?¯ => %{
        name: "macron",
        bitmap:
          defbitmap([
            "XXXXX",
            "     ",
            "     ",
            "     ",
            "     ",
            "     ",
            "     "
          ])
      },
      ?° => %{
        name: "degree sign",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            " X ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?± => %{
        name: "plus-minus sign",
        bitmap:
          defbitmap([
            "  X  ",
            "  X  ",
            "XXXXX",
            "  X  ",
            "  X  ",
            "     ",
            "XXXXX"
          ])
      },
      ?² => %{
        name: "superscript two",
        bitmap:
          defbitmap([
            "XX ",
            "  X",
            " X ",
            "X  ",
            "XXX",
            "   ",
            "   "
          ])
      },
      ?³ => %{
        name: "superscript three",
        bitmap:
          defbitmap([
            "XX ",
            "  X",
            " X ",
            "  X",
            "XX ",
            "   ",
            "   "
          ])
      },
      ?´ => %{
        name: "acute accent",
        bitmap:
          defbitmap(
            [
              " X",
              "X "
            ],
            baseline_y: 5
          )
      },
      ?µ => %{
        name: "micro sign",
        bitmap:
          defbitmap(
            [
              "    ",
              "    ",
              "    ",
              "   X",
              "X  X",
              "X  X",
              "XXX ",
              "X   ",
              "X   "
            ],
            baseline_y: -1
          )
      },
      ?· => %{
        name: "middle dot",
        bitmap:
          defbitmap([
            " ",
            " ",
            " ",
            "X",
            " ",
            " ",
            " "
          ])
      },
      ?¹ => %{
        name: "superscript one",
        bitmap:
          defbitmap([
            " X ",
            "XX ",
            " X ",
            " X ",
            "XXX",
            "   ",
            "   "
          ])
      },
      ?ª => %{
        name: "feminine ordinal indicator",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "XXX",
            "X X",
            "   ",
            "   ",
            "   "
          ])
      },
      ?º => %{
        name: "masculine ordinal indicator",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            " X ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?« => %{
        name: "left-pointing double angle quotation mark",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " X X ",
            "X X  ",
            " X X ",
            "     ",
            "     "
          ])
      },
      ?¬ => %{
        name: "not sign",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "     ",
            "XXXXX",
            "    X",
            "     ",
            "     "
          ])
      },
      ?» => %{
        name: "right-pointing double angle quotation mark",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " X X ",
            "  X X",
            " X X ",
            "     ",
            "     "
          ])
      },
      ?¼ => %{
        name: "vulgar fraction one quarter",
        bitmap:
          defbitmap([
            " X      X   ",
            "XX     X    ",
            " X    X X  X",
            " X   X  X  X",
            " X  X   XXXX",
            "   X       X",
            "  X        X"
          ])
      },
      ?½ => %{
        name: "vulgar fraction one half",
        bitmap:
          defbitmap([
            " X      X   ",
            "XX     X    ",
            " X    X  XX ",
            " X   X  X  X",
            " X  X     X ",
            "   X     X  ",
            "  X     XXXX"
          ])
      },
      ?¾ => %{
        name: "vulgar fraction three quarters",
        bitmap:
          defbitmap([
            " XX      X    ",
            "X  X    X     ",
            "  X    X  X  X",
            "X  X  X   X  X",
            " XX  X    XXXX",
            "    X        X",
            "   X         X"
          ])
      },
      ?¿ => %{
        name: "question mark",
        bitmap:
          defbitmap([
            "  X  ",
            "     ",
            "  X  ",
            "  X  ",
            "   X ",
            "X   X",
            " XXX "
          ])
      }
    }
  }

  def get(), do: @font
end
