defmodule Flipdot.Font.Fonts.Flipdot do
  alias Flipdot.Bitmap
  import Bitmap
  alias Flipdot.Font

  @font %Font{
    name: "flipdot",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Flipdot",
      foundry: "AAA",
      weight_name: "Normal",
      slant: "R",
      pixel_size: 7
    },
    characters: %{
      0 => %{
        name: "defaultchar",
        bitmap:
          defbitmap([
            "XXXXX",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "XXXXX"
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
            "X",
            "X",
            "X",
            "X",
            "X",
            " ",
            "X"
          ])
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap([
            " X X ",
            " X X ",
            "XXXXX",
            " X X ",
            "XXXXX",
            " X X ",
            " X X "
          ])
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap([
            "  X  ",
            " XXX ",
            "X X X",
            "X X  ",
            " XXX ",
            "  X X",
            "X X X",
            " XXX ",
            "  X  "
          ], baseline_y: -1)
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap([
            "XX X ",
            "XX X ",
            "  X  ",
            "  X  ",
            "  X  ",
            " X XX",
            " X XX"
          ])
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap([
            " XX  ",
            "X  X ",
            "X  X ",
            " XX  ",
            "X  X ",
            "X   X",
            " XXXX"
          ])
      },
      ?' => %{
        name: "apostrophe",
        bitmap:
          defbitmap([
            "X",
            "X",
            " ",
            " ",
            " ",
            " ",
            " "
          ])
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap([
            "  X",
            " X ",
            "X  ",
            "X  ",
            "X  ",
            " X ",
            "  X"
          ])
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap([
            "X  ",
            " X ",
            "  X",
            "  X",
            "  X",
            " X ",
            "X  "
          ])
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap([
            "  X  ",
            "X X X",
            " XXX ",
            "  X  ",
            " XXX ",
            "X X X",
            "  X  "
          ])
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap([
            "     ",
            "  X  ",
            "  X  ",
            "XXXXX",
            "  X  ",
            "  X  ",
            "     "
          ])
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap([
            "X",
            "X"
          ], baseline_y: -1)
      },
      ?- => %{
        name: "hyphen",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "     ",
            "XXXXX",
            "     ",
            "     ",
            "     "
          ])
      },
      ?. => %{
        name: "period",
        bitmap:
          defbitmap([
            "X"
          ])
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap([
            "  X",
            "  X",
            " X ",
            " X ",
            " X ",
            "X  ",
            "X  "
          ])
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X  XX",
            "X X X",
            "XX  X",
            "X   X",
            " XXX "
          ])
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap([
            " X ",
            "XX ",
            " X ",
            " X ",
            " X ",
            " X ",
            "XXX"
          ])
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "    X",
            "  XX ",
            " X   ",
            "X    ",
            "XXXXX"
          ])
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap([
            "XXXXX",
            "    X",
            "   X ",
            "  XX ",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap([
            "   X ",
            "  XX ",
            " X X ",
            "X  X ",
            "XXXXX",
            "   X ",
            "   X "
          ])
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap([
            "XXXXX",
            "X    ",
            "X    ",
            " XXX ",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X    ",
            "XXXX ",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap([
            "XXXXX",
            "    X",
            "   X ",
            "  X  ",
            " X   ",
            " X   ",
            " X   "
          ])
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            " XXX ",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            " XXXX",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap([
            " ",
            "X",
            " ",
            " ",
            " ",
            "X"
          ])
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap([
            " ",
            "X",
            " ",
            " ",
            "X",
            "X"
          ], baseline_y: 0)
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap([
            "   X",
            "  X ",
            " X  ",
            "X   ",
            " X  ",
            "  X ",
            "   X"
          ])
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "XXXXX",
            "     ",
            "XXXXX",
            "     ",
            "     "
          ])
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap([
            "X   ",
            " X  ",
            "  X ",
            "   X",
            "  X ",
            " X  ",
            "X   "
          ])
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "   X ",
            "  X  ",
            "  X  ",
            "     ",
            "  X  "
          ])
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X X X",
            "XX XX",
            "X X  ",
            "X   X",
            " XXX "
          ])
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap([
            "  X  ",
            " X X ",
            "X   X",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap([
            "XXXX ",
            "X   X",
            "X   X",
            "XXXX ",
            "X   X",
            "X   X",
            "XXXX "
          ])
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X    ",
            "X    ",
            "X    ",
            "X   X",
            " XXX "
          ])
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap([
            "XXXX ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "XXXX "
          ])
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap([
            "XXXXX",
            "X    ",
            "X    ",
            "XXXX ",
            "X    ",
            "X    ",
            "XXXXX"
          ])
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap([
            "XXXXX",
            "X    ",
            "X    ",
            "XXXX ",
            "X    ",
            "X    ",
            "X    "
          ])
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X    ",
            "X XXX",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X",
            "X   X"
          ])
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap([
            "XXX",
            " X ",
            " X ",
            " X ",
            " X ",
            " X ",
            "XXX"
          ])
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap([
            "    X",
            "    X",
            "    X",
            "    X",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap([
            "X   X",
            "X  X ",
            "X X  ",
            "XX   ",
            "X X  ",
            "X  X ",
            "X   X"
          ])
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap([
            "X    ",
            "X    ",
            "X    ",
            "X    ",
            "X    ",
            "X    ",
            "XXXXX"
          ])
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap([
            "X   X",
            "XX XX",
            "X X X",
            "X X X",
            "X   X",
            "X   X",
            "X   X"
          ])
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "XX  X",
            "X X X",
            "X  XX",
            "X   X",
            "X   X"
          ])
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap([
            "XXXX ",
            "X   X",
            "X   X",
            "XXXX ",
            "X    ",
            "X    ",
            "X    "
          ])
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            "X X X",
            "X  XX",
            " XXXX"
          ])
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap([
            "XXXX ",
            "X   X",
            "X   X",
            "XXXX ",
            "X X  ",
            "X  X ",
            "X   X"
          ])
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X    ",
            " XXX ",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap([
            "XXXXX",
            "  X  ",
            "  X  ",
            "  X  ",
            "  X  ",
            "  X  ",
            "  X  "
          ])
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " X X ",
            "  X  "
          ])
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "X   X",
            "X X X",
            "X X X",
            "XX XX",
            "X   X"
          ])
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            " X X ",
            "  X  ",
            " X X ",
            "X   X",
            "X   X"
          ])
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            " X X ",
            "  X  ",
            "  X  ",
            "  X  ",
            "  X  "
          ])
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap([
            "XXXXX",
            "    X",
            "   X ",
            "  X  ",
            " X   ",
            "X    ",
            "XXXXX"
          ])
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap([
            " XX",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            " XX"
          ])
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            " X ",
            " X ",
            " X ",
            "  X",
            "  X"
          ])
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap([
            "XX ",
            "  X",
            "  X",
            "  X",
            "  X",
            "  X",
            "XX "
          ])
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap([
            "  X  ",
            " X X ",
            "X   X",
            "     ",
            "     ",
            "     ",
            "     "
          ])
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "     ",
            "     ",
            "     ",
            "     ",
            "XXXXX"
          ])
      },
      ?` => %{
        name: "grave accent",
        bitmap:
          defbitmap([
            "X ",
            " X",
            "  ",
            "  ",
            "  ",
            "  ",
            "  "
          ])
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXX ",
            "    X",
            " XXXX",
            "X   X",
            " XXXX"
          ])
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap([
            "X    ",
            "X    ",
            "XXXX ",
            "X   X",
            "X   X",
            "X   X",
            "XXXX "
          ])
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXXX",
            "X    ",
            "X    ",
            "X    ",
            " XXXX"
          ])
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap([
            "    X",
            "    X",
            " XXXX",
            "X   X",
            "X   X",
            "X   X",
            " XXXX"
          ])
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXX ",
            "X   X",
            "XXXXX",
            "X    ",
            " XXX "
          ])
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap([
            " XX",
            "X  ",
            "X  ",
            "XX ",
            "X  ",
            "X  ",
            "X  "
          ])
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap([
            "     ",
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            " XXXX",
            "    X",
            " XXX "
          ], baseline_y: -2)
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap([
            "X    ",
            "X    ",
            "XXXX ",
            "X   X",
            "X   X",
            "X   X",
            "X   X"
          ])
      },
      ?ï => %{
        name: "i diaeresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            " X ",
            " X ",
            " X ",
            " X ",
            " X "
          ])
      },
      ?i => %{
        name: "i",
        bitmap:
          defbitmap([
            "X",
            " ",
            "X",
            "X",
            "X",
            "X",
            "X"
          ])
      },
      ?j => %{
        name: "j",
        bitmap:
          defbitmap([
            "  X",
            "   ",
            "  X",
            "  X",
            "  X",
            "  X",
            "  X",
            "XX "
          ], baseline_y: -2)
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap([
            "X   ",
            "X   ",
            "X  X",
            "X X ",
            "XX  ",
            "X X ",
            "X  X"
          ])
      },
      ?l => %{
        name: "l",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            " XX"
          ])
      },
      ?m => %{
        name: "m",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "XX X ",
            "X X X",
            "X X X",
            "X X X",
            "X X X"
          ])
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap([
            "    ",
            "    ",
            "X X ",
            "XX X",
            "X  X",
            "X  X",
            "X  X"
          ])
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap([
            "XXXX ",
            "X   X",
            "X   X",
            "X   X",
            "XXXX ",
            "X    ",
            "X    "
          ], baseline_y: -2)
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            " XXXX",
            "    X",
            "    X"
          ], baseline_y: -2)
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap([
            "    ",
            "    ",
            " XXX",
            "X   ",
            "X   ",
            "X   ",
            "X   "
          ])
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXXX",
            "X    ",
            " XXX ",
            "    X",
            "XXXX "
          ])
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap([
            " X ",
            " X ",
            "XXX",
            " X ",
            " X ",
            " X ",
            "  X"
          ])
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "X   X",
            "X   X",
            "X   X",
            " X X ",
            "  X  "
          ])
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "X   X",
            "X X X",
            "X X X",
            "XX XX",
            "X   X"
          ])
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "X   X",
            " X X ",
            "  X  ",
            " X X ",
            "X   X"
          ])
      },
      ?y => %{
        name: "y",
        bitmap:
          defbitmap([
            "X   X",
            "X   X",
            "X   X",
            " X X ",
            "  X  ",
            "  X  ",
            "  X  "
          ], baseline_y: -2)
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "XXXXX",
            "   X ",
            "  X  ",
            " X   ",
            "XXXXX"
          ])
      },
      ?{ => %{
        name: "left curly brace",
        bitmap:
          defbitmap([
            "  X",
            " X ",
            " X ",
            "X  ",
            " X ",
            " X ",
            "  X"
          ])
      },
      ?| => %{
        name: "vertical bar",
        bitmap:
          defbitmap([
            "X",
            "X",
            "X",
            "X",
            "X",
            "X",
            "X"
          ])
      },
      ?} => %{
        name: "right curly brace",
        bitmap:
          defbitmap([
            "X  ",
            " X ",
            " X ",
            "  X",
            " X ",
            " X ",
            "X  "
          ])
      },
      ?~ => %{
        name: "tilde",
        bitmap:
          defbitmap([
            "    ",
            "    ",
            " X X",
            "X X ",
            "    ",
            "    ",
            "    "
          ])
      },

      # ISO 8859-1 CHARACTERS

      160 => %{
        name: "no-break space",
        bitmap:
          defbitmap([
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " "
          ])
      },
      ?¡ => %{
        name: "inverted exclamation mark",
        bitmap:
          defbitmap([
            "X",
            " ",
            "X",
            "X",
            "X",
            "X",
            "X"
          ])
      },
      ?¢ => %{
        name: "cent sign",
        bitmap:
          defbitmap([
            "     ",
            "  XXX",
            " X   ",
            "XXXX ",
            " X   ",
            "  XXX",
            "     "
          ])
      },
      ?£ => %{
        name: "pound sign",
        bitmap:
          defbitmap([
            "  XXX",
            " X   ",
            " X   ",
            "XXXX ",
            " X   ",
            " X   ",
            "XXXXX"
          ])
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap([
            "     ",
            "X   X",
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            " XXX ",
            "X   X"
          ])
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap([
            "X   X",
            " X X ",
            "XXXXX",
            "  X  ",
            "XXXXX",
            "  X  ",
            "  X  "
          ])
      },
      ?¦ => %{
        name: "broken bar",
        bitmap:
          defbitmap([
            "X",
            "X",
            "X",
            " ",
            "X",
            "X",
            "X"
          ])
      },
      ?§ => %{
        name: "section sign",
        bitmap:
          defbitmap([
            " XXX ",
            "X    ",
            " X   ",
            " XXX ",
            "X   X",
            " XXX ",
            "   X ",
            "    X",
            " XXX "
          ], baseline_y: -1)
      },
      ?ß => %{
        name: "sharp s",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X  X ",
            "X X  ",
            "X  X ",
            "X   X",
            "X XX ",
            "X    "
          ], baseline_y: -1)
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap([
            "X   X",
            "  X  ",
            " X X ",
            "X   X",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap([
            " X X ",
            "     ",
            " XXX ",
            "    X",
            " XXXX",
            "X   X",
            " XXXX"
          ])
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap([
            "X   X",
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap([
            " X X ",
            "     ",
            " XXX ",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap([
            "X   X",
            "     ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap([
            " X X ",
            "     ",
            "X   X",
            "X   X",
            "X   X",
            "X   X",
            " XXX "
          ])
      },
      ?¨ => %{
        name: "diaresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?© => %{
        name: "copyright sign",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "  X  ",
            " X X ",
            " X   ",
            " X X ",
            "  X  ",
            "X   X",
            " XXX "
          ], baseline_y: -1)
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
          defbitmap([
            " X",
            "X "
          ], baseline_y: 5)
      },
      ?µ => %{
        name: "micro sign",
        bitmap:
          defbitmap([
            "    ",
            "    ",
            "    ",
            "   X",
            "X  X",
            "X  X",
            "XXX ",
            "X   ",
            "X   "
          ], baseline_y: -1)
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
            "  X X",
            " X X ",
            "X X  ",
            " X X ",
            "  X X",
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
            "X X  ",
            " X X ",
            "  X X",
            " X X ",
            "X X  ",
            "     "
          ])
      },
      ?¼ => %{
        name: "vulgar fraction one quarter",
        bitmap:
          defbitmap([
            " X ",
            " X ",
            " X ",
            "   ",
            "X X",
            "XXX",
            "  X"
          ])
      },
      ?½ => %{
        name: "vulgar fraction one half",
        bitmap:
          defbitmap([
            " X ",
            " X ",
            " X ",
            "   ",
            "XX ",
            " X ",
            " XX"
          ])
      },
      ?¾ => %{
        name: "vulgar fraction three quarters",
        bitmap:
          defbitmap([
            "XX ",
            " XX",
            "XX ",
            "   ",
            "X X",
            "XXX",
            "  X"
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
      },

      # SPACE INVADERS

      ?á => %{
        name: "crab_invader_0",
        bitmap:
          defbitmap([
            "  X     X  ",
            "   X   X   ",
            "  XXXXXXX  ",
            " XX XXX XX ",
            "XXXXXXXXXXX",
            "X XXXXXXX X",
            "X X     X X",
            "   XX XX   "
          ])
      },
      ?à => %{
        name: "crab_invader_1",
        bitmap:
          defbitmap([
            "  X     X  ",
            "X  X   X  X",
            "X XXXXXXX X",
            "XXX XXX XXX",
            "XXXXXXXXXXX",
            " XXXXXXXXX ",
            "  X     X  ",
            " X       X "
          ])
      },
      ?í => %{
        name: "squid_invader_0",
        bitmap:
          defbitmap([
            "   XX   ",
            "  XXXX  ",
            " XXXXXX ",
            "XX XX XX",
            "XXXXXXXX",
            "  X  X  ",
            " X XX X ",
            "X X  X X"
          ])
      },
      ?ì => %{
        name: "squid_invader_1",
        bitmap:
          defbitmap([
            "   XX   ",
            "  XXXX  ",
            " XXXXXX ",
            "XX XX XX",
            "XXXXXXXX",
            " X XX X ",
            "X      X",
            " X    X "
          ])
      },
      ?ó => %{
        name: "octopus_invader_0",
        bitmap:
          defbitmap([
            "    XXXX    ",
            " XXXXXXXXXX ",
            "XXXXXXXXXXXX",
            "XXX  XX  XXX",
            "XXXXXXXXXXXX",
            "   XX  XX   ",
            "  XX XX XX  ",
            "XX        XX"
          ])
      },
      ?ò => %{
        name: "octopus_invader_1",
        bitmap:
          defbitmap([
            "    XXXX    ",
            " XXXXXXXXXX ",
            "XXXXXXXXXXXX",
            "XXX  XX  XXX",
            "XXXXXXXXXXXX",
            "  XXX  XXX  ",
            " XX  XX  XX ",
            "  XX    XX  "
          ])
      },
      ?å => %{
        name: "invader_ufo",
        bitmap:
          defbitmap([
            "     XXXXXX     ",
            "   XXXXXXXXXX   ",
            "  XXXXXXXXXXXX  ",
            " XX XX XX XX XX ",
            "XXXXXXXXXXXXXXXX",
            "  XXX  XX   XXX ",
            "   X         X  "
          ])
      },
      0xF72E => %{
        name: "wind",
        bitmap:
          defbitmap([
            "     XX   ",
            "       X  ",
            "XXXXXXX   ",
            "          ",
            "XXXXXXXXX ",
            "         X",
            "XXXX   XX ",
            "    X     ",
            "  XX      "
          ], baseline_y: -1)
      },
      0xF73D => %{
        name: "rain",
        bitmap:
          defbitmap([
            "  XX     ",
            " XXXX XX ",
            "XXXXXXXXX",
            "XXXXXXXXX",
            "XXXXXXXXX",
            " XXXXXXX ",
            "         ",
            " X  X  X ",
            "  X  X  X"
          ], baseline_y: -1)
      },
      0xF017 => %{
        name: "clock",
        bitmap:
          defbitmap([
            "  XXX  ",
            " X X X ",
            "X  X  X",
            "X  X  X",
            "X   X X",
            " X   X ",
            "  XXX  "
          ])
      },
      0xF018 => %{
        name: "m/s",
        bitmap:
          defbitmap([
            "      X     ",
            "XX X  X  XXX",
            "X X X X X   ",
            "X X X X  XX ",
            "X X X X    X",
            "X X X X XXX ",
            "      X     "
          ])
      },
      0x1FFF2 => %{
        name: "clock-face-three-oclock",
        bitmap:
          defbitmap([
            "  XXX  ",
            " X X X ",
            "X  X  X",
            "X  XXXX",
            "X     X",
            " X   X ",
            "  XXX  "
          ])
      },
      0x1FFF5 => %{
        name: "clock-face-six-oclock",
        bitmap:
          defbitmap([
            "  XXX  ",
            " X X X ",
            "X  X  X",
            "X  X  X",
            "X  X  X",
            " X X X ",
            "  XXX  "
          ])
      },
      0x1FFF8 => %{
        name: "clock-face-nine-oclock",
        bitmap:
          defbitmap([
            "  XXX  ",
            " X X X ",
            "X  X  X",
            "XXXX  X",
            "X     X",
            " X   X ",
            "  XXX  "
          ])
      },
      0x1FFFB => %{
        name: "clock-face-twelve-oclock",
        bitmap:
          defbitmap([
            "  XXX  ",
            " X X X ",
            "X  X  X",
            "X  X  X",
            "X     X",
            " X   X ",
            "  XXX  "
          ])
      },
      0x2744 => %{
        name: "snowflake",
        bitmap:
          defbitmap([
            "    X    ",
            " X  X  X ",
            "  X X X  ",
            "   XXX   ",
            "XXXX XXXX",
            "   XXX   ",
            "  X X X  ",
            " X  X  X ",
            "    X    "
          ], baseline_y: -1)
      },
      ?ツ => %{
        name: "katakana-letter-tu",
        bitmap:
          defbitmap([
            "  X    X",
            "X  X   X",
            " X    X ",
            "      X ",
            "     X  ",
            "   XX   ",
            " XX     "
          ])
      },
      0xF2C9 => %{
        name: "thermometer-half",
        bitmap:
          defbitmap([
            "   XXX   ",
            "  X   X  ",
            "  X   X  ",
            "  X X X  ",
            "  X X X  ",
            " X XXX X ",
            "X XXXXX X",
            " X XXX X ",
            "  XXXXX  "
          ], baseline_y: -1)
      }
    }
  }

  def get(), do: @font
end
