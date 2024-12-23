defmodule Flipdot.Font.Fonts.Letterbox do
  import Bitmap
  alias Flipdot.Font

  @font %Font{
    name: "letterbox",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Letterbox",
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
            "        ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        "
          ])
      },
      ?! => %{
        name: "exclamation mark",
        bitmap:
          defbitmap([
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "        ",
            "   XX   "
          ])
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        "
          ])
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            "XXXXXXXX",
            " XX  XX ",
            "XXXXXXXX",
            " XX  XX ",
            " XX  XX "
          ])
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap([
            "   XX   ",
            " XXXXXX ",
            "XX XX   ",
            " XXXXXX ",
            "   XX XX",
            " XXXXXX ",
            "   XX   "
          ])
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            " XX  XX ",
            " XX  XX "
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
            "   XX   ",
            "   XX   ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        "
          ])
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap([
            "    XX  ",
            "   XX   ",
            "  XX    ",
            "  XX    ",
            "  XX    ",
            "   XX   ",
            "    XX  "
          ])
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap([
            "  XX    ",
            "   XX   ",
            "    XX  ",
            "    XX  ",
            "    XX  ",
            "   XX   ",
            "  XX    "
          ])
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap([
            "   XX   ",
            "XX XX XX",
            " XXXXXX ",
            "XXXXXXXX",
            " XXXXXX ",
            "XX XX XX",
            "   XX   "
          ])
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap([
            "        ",
            "   XX   ",
            "   XX   ",
            " XXXXXX ",
            " XXXXXX ",
            "   XX   ",
            "   XX   "
          ])
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap([
            " X",
            "X "
          ], baseline_y: -1)
      },
      ?- => %{
        name: "hyphen-minus",
        bitmap:
          defbitmap([
            "        ",
            "        ",
            "        ",
            " XXXXXX ",
            " XXXXXX ",
            "        ",
            "        "
          ])
      },
      ?. => %{
        name: "full stop",
        bitmap:
          defbitmap([
            "   XX   ",
            "   XX   "
          ])
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap([
            "     XX ",
            "     XX ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            " XX     ",
            " XX     "
          ])
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap([
            "   XX   ",
            "  XXX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "  XXXX  "
          ])
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            " XX     ",
            " XXXXXX "
          ])
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            "     XX ",
            "    XX  ",
            "     XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap([
            " XX     ",
            " XX  XX ",
            " XX  XX ",
            " XXXXXX ",
            "     XX ",
            "     XX ",
            "     XX "
          ])
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap([
            " XXXXXX ",
            " XX     ",
            " XXXXX  ",
            "     XX ",
            "     XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX     ",
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap([
            " XXXXXX ",
            "     XX ",
            "    XX  ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   "
          ])
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            "  XXXXX ",
            "     XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap([
            "   XX   ",
            "   XX   ",
            "        ",
            "   XX   ",
            "   XX   ",
            "        "
          ])
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap([
            "   XX   ",
            "   XX   ",
            "        ",
            "   XX   ",
            "   XX   ",
            "  XX    "
          ])
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap([
            "        ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            "   XX   ",
            "    XX  ",
            "        "
          ])
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap([
            " XXXXXX ",
            "        ",
            " XXXXXX ",
            "        ",
            "        "
          ])
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap([
            "        ",
            "  XX    ",
            "   XX   ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            "        "
          ])
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            "    XX  ",
            "   XX   ",
            "   XX   ",
            "        ",
            "   XX   "
          ])
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap([
            " XXXXXX ",
            "XX    XX",
            "XX  X XX",
            "XX XX XX",
            "XX  XXX ",
            " XX     ",
            "  XXXXX "
          ])
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XXXXXX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX "
          ])
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap([
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XXXXX  "
          ])
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap([
            "  XXXXX ",
            " XX     ",
            " XX     ",
            " XX     ",
            " XX     ",
            " XX     ",
            "  XXXXX "
          ])
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap([
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XXXXX  "
          ])
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap([
            " XXXXXX ",
            " XX     ",
            " XX     ",
            " XXXX   ",
            " XX     ",
            " XX     ",
            " XXXXXX "
          ])
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap([
            " XXXXXX ",
            " XX     ",
            " XX     ",
            " XXXX   ",
            " XX     ",
            " XX     ",
            " XX     "
          ])
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX     ",
            " XX XXX ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XXXXXX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX "
          ])
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap([
            "  XXXX  ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "  XXXX  "
          ])
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap([
            "     XX ",
            "     XX ",
            "     XX ",
            "     XX ",
            "     XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap([
            " XX   XX ",
            " XX  XX  ",
            " XX XX   ",
            " XXXX    ",
            " XX XX   ",
            " XX  XX  ",
            " XX   XX "
          ])
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap([
            " XX     ",
            " XX     ",
            " XX     ",
            " XX     ",
            " XX     ",
            " XX     ",
            " XXXXXX "
          ])
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap([
            " XX   XX ",
            " XXX XXX ",
            " XXXXXXX ",
            " XX X XX ",
            " XX   XX ",
            " XX   XX ",
            " XX   XX "
          ])
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap([
            " XX   XX ",
            " XXX  XX ",
            " XXXX XX ",
            " XX XXXX ",
            " XX  XXX ",
            " XX   XX ",
            " XX   XX "
          ])
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap([
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XXXXX  ",
            " XX     ",
            " XX     ",
            " XX     "
          ])
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX XX  ",
            "  XX XX "
          ])
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap([
            " XXXXX  ",
            " XX  XX ",
            " XX  XX ",
            " XXXXX  ",
            " XX XX  ",
            " XX  XX ",
            " XX  XX "
          ])
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap([
            "  XXXX  ",
            " XX  XX ",
            " XX     ",
            "  XXXX  ",
            "     XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap([
            " XXXXXX ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   ",
            "   XX   "
          ])
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  "
          ])
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap([
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            " XX  XX ",
            "  XXXX  ",
            "   XX   "
          ])
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap([
            "XX    XX",
            "XX    XX",
            "XX    XX",
            "XX    XX",
            "XX XX XX",
            "XXX  XXX",
            "XX    XX"
          ])
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap([
            "XX    XX",
            "XX    XX",
            " XX  XX ",
            "  XXXX  ",
            " XX  XX ",
            "XX    XX",
            "XX    XX"
          ])
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap([
            "XX    XX",
            "XX    XX",
            " XX  XX ",
            "  XXXX  ",
            "   XX   ",
            "   XX   ",
            "   XX   "
          ])
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap([
            " XXXXXX ",
            "     XX ",
            "    XX  ",
            "   XX   ",
            "  XX    ",
            " XX     ",
            " XXXXXX "
          ])
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap([
            "  XXXX  ",
            "  XX    ",
            "  XX    ",
            "  XX    ",
            "  XX    ",
            "  XX    ",
            "  XXXX  "
          ])
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap([
            " XX     ",
            " XX     ",
            "  XX    ",
            "   XX   ",
            "    XX  ",
            "     XX ",
            "     XX "
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
            "  XXX  ",
            " XX XX ",
            "XX   XX",
            "       ",
            "       ",
            "       ",
            "       "
          ])
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap([
            "        ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        ",
            " XXXXXX "
          ])
      },
      ?` => %{
        name: "grave accent",
        bitmap:
          defbitmap([
            "  XX    ",
            "   XX   ",
            "        ",
            "        ",
            "        ",
            "        ",
            "        "
          ])
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXXX",
            "X   X",
            "X   X",
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
            " XXXX"
          ])
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap([
            "  XX",
            " X  ",
            " X  ",
            "XXXX",
            " X  ",
            " X  ",
            " X  "
          ])
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "     ",
            " XXXX",
            "X   X",
            " XXXX",
            "    X",
            "XXXX "
          ])
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
            "   X",
            "    ",
            "   X",
            "   X",
            "   X",
            "X  X",
            " XX "
          ])
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap([
            "X   ",
            "X  X",
            "X X ",
            "XX  ",
            "X X ",
            "X  X",
            "X  X"
          ])
      },
      ?l => %{
        name: "l",
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
      ?m => %{
        name: "m",
        bitmap:
          defbitmap([
            "       ",
            "       ",
            "XXX XX ",
            "X  X  X",
            "X  X  X",
            "X  X  X",
            "X  X  X"
          ])
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            "XXXX ",
            "X   X",
            "X   X",
            "X   X",
            "X   X"
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
            "     ",
            "     ",
            "XXXX ",
            "X   X",
            "XXXX ",
            "X    ",
            "X    "
          ])
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap([
            "     ",
            "     ",
            " XXXX",
            "X   X",
            " XXXX",
            "    X",
            "    X"
          ])
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
            " X "
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
            "       ",
            "       ",
            "X     X",
            "X     X",
            "X  X  X",
            "X  X  X",
            " XX XX "
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
            "     ",
            "     ",
            "X   X",
            "X   X",
            " XXXX",
            "    X",
            "XXXX "
          ])
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
            "     ",
            "     ",
            " X   ",
            "X X X",
            "   X ",
            "     ",
            "     "
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
            "     ",
            "X   X",
            "     ",
            " XXX ",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?Á => %{
        name: "A with acute accent",
        bitmap:
          defbitmap([
            "   X ",
            "  X  ",
            "     ",
            " XXX ",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?À => %{
        name: "A with grave accent",
        bitmap:
          defbitmap([
            " X   ",
            "  X  ",
            "     ",
            " XXX ",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?Å => %{
        name: "A with ring",
        bitmap:
          defbitmap([
            " XXX ",
            " XXX ",
            "     ",
            " XXX ",
            "X   X",
            "XXXXX",
            "X   X",
            "X   X"
          ])
      },
      ?Ã => %{
        name: "A with tilde",
        bitmap:
          defbitmap([
            " XX X",
            "X XX ",
            "     ",
            " XXX ",
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
            "X   X",
            "     ",
            " XXXX",
            "X   X",
            "X   X",
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
