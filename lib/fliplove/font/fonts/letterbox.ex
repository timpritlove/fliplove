defmodule Fliplove.Font.Fonts.Letterbox do
  alias Fliplove.Bitmap
  import Bitmap
  alias Fliplove.Font

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
          defbitmap do
            "XXXXX"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "XXXXX"
          end
      },
      ?\s => %{
        name: "space",
        bitmap:
          defbitmap do
            "        "
            "        "
            "        "
            "        "
            "        "
            "        "
            "        "
          end
      },
      ?! => %{
        name: "exclamation mark",
        bitmap:
          defbitmap do
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "        "
            "   XX   "
          end
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            "        "
            "        "
            "        "
            "        "
            "        "
          end
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            "XXXXXXXX"
            " XX  XX "
            "XXXXXXXX"
            " XX  XX "
            " XX  XX "
          end
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap do
            "   XX   "
            " XXXXXX "
            "XX XX   "
            " XXXXXX "
            "   XX XX"
            " XXXXXX "
            "   XX   "
          end
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            "    XX  "
            "   XX   "
            "  XX    "
            " XX  XX "
            " XX  XX "
          end
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap do
            " XXXX   "
            "XX  XX  "
            "XX  XX  "
            " XXXX   "
            "XX XX XX"
            "XX  XX  "
            " XXX XX "
          end
      },
      ?' => %{
        name: "apostrophe",
        bitmap:
          defbitmap do
            "   XX   "
            "   XX   "
            "        "
            "        "
            "        "
            "        "
            "        "
          end
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap do
            "    XX  "
            "   XX   "
            "  XX    "
            "  XX    "
            "  XX    "
            "   XX   "
            "    XX  "
          end
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap do
            "  XX    "
            "   XX   "
            "    XX  "
            "    XX  "
            "    XX  "
            "   XX   "
            "  XX    "
          end
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap do
            "   XX   "
            "XX XX XX"
            " XXXXXX "
            "XXXXXXXX"
            " XXXXXX "
            "XX XX XX"
            "   XX   "
          end
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap do
            "        "
            "   XX   "
            "   XX   "
            " XXXXXX "
            " XXXXXX "
            "   XX   "
            "   XX   "
          end
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap baseline_y: -1 do
            " X"
            "X "
          end
      },
      ?- => %{
        name: "hyphen-minus",
        bitmap:
          defbitmap do
            "        "
            "        "
            "        "
            " XXXXXX "
            " XXXXXX "
            "        "
            "        "
          end
      },
      ?. => %{
        name: "full stop",
        bitmap:
          defbitmap do
            "   XX   "
            "   XX   "
          end
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap do
            "     XX "
            "     XX "
            "    XX  "
            "   XX   "
            "  XX    "
            " XX     "
            " XX     "
          end
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap do
            "   XX   "
            "  XXX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "  XXXX  "
          end
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            "    XX  "
            "   XX   "
            "  XX    "
            " XX     "
            " XXXXXX "
          end
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            "     XX "
            "    XX  "
            "     XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap do
            " XX     "
            " XX  XX "
            " XX  XX "
            " XXXXXX "
            "     XX "
            "     XX "
            "     XX "
          end
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap do
            " XXXXXX "
            " XX     "
            " XXXXX  "
            "     XX "
            "     XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX     "
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap do
            " XXXXXX "
            "     XX "
            "    XX  "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
          end
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            "  XXXXX "
            "     XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap do
            "   XX   "
            "   XX   "
            "        "
            "   XX   "
            "   XX   "
            "        "
          end
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap do
            "   XX   "
            "   XX   "
            "        "
            "   XX   "
            "   XX   "
            "  XX    "
          end
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap do
            "        "
            "    XX  "
            "   XX   "
            "  XX    "
            "   XX   "
            "    XX  "
            "        "
          end
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap do
            " XXXXXX "
            "        "
            " XXXXXX "
            "        "
            "        "
          end
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap do
            "        "
            "  XX    "
            "   XX   "
            "    XX  "
            "   XX   "
            "  XX    "
            "        "
          end
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            "    XX  "
            "   XX   "
            "   XX   "
            "        "
            "   XX   "
          end
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap do
            " XXXXXX "
            "XX    XX"
            "XX  X XX"
            "XX XX XX"
            "XX  XXX "
            " XX     "
            "  XXXXX "
          end
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            " XXXXXX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
          end
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap do
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            " XXXXX  "
          end
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap do
            "  XXXXX "
            " XX     "
            " XX     "
            " XX     "
            " XX     "
            " XX     "
            "  XXXXX "
          end
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap do
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XXXXX  "
          end
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap do
            " XXXXXX "
            " XX     "
            " XX     "
            " XXXX   "
            " XX     "
            " XX     "
            " XXXXXX "
          end
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap do
            " XXXXXX "
            " XX     "
            " XX     "
            " XXXX   "
            " XX     "
            " XX     "
            " XX     "
          end
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX     "
            " XX XXX "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XXXXXX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
          end
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap do
            "  XXXX  "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "  XXXX  "
          end
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap do
            "     XX "
            "     XX "
            "     XX "
            "     XX "
            "     XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap do
            " XX   XX "
            " XX  XX  "
            " XX XX   "
            " XXXX    "
            " XX XX   "
            " XX  XX  "
            " XX   XX "
          end
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap do
            " XX     "
            " XX     "
            " XX     "
            " XX     "
            " XX     "
            " XX     "
            " XXXXXX "
          end
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap do
            " XX   XX "
            " XXX XXX "
            " XXXXXXX "
            " XX X XX "
            " XX   XX "
            " XX   XX "
            " XX   XX "
          end
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap do
            " XX   XX "
            " XXX  XX "
            " XXXX XX "
            " XX XXXX "
            " XX  XXX "
            " XX   XX "
            " XX   XX "
          end
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap do
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            " XXXXX  "
            " XX     "
            " XX     "
            " XX     "
          end
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX XX  "
            "  XX XX "
          end
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap do
            " XXXXX  "
            " XX  XX "
            " XX  XX "
            " XXXXX  "
            " XX XX  "
            " XX  XX "
            " XX  XX "
          end
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap do
            "  XXXX  "
            " XX  XX "
            " XX     "
            "  XXXX  "
            "     XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap do
            " XXXXXX "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
            "   XX   "
          end
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
          end
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap do
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            " XX  XX "
            "  XXXX  "
            "   XX   "
          end
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap do
            "XX    XX"
            "XX    XX"
            "XX    XX"
            "XX    XX"
            "XX XX XX"
            "XXX  XXX"
            "XX    XX"
          end
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap do
            "XX    XX"
            "XX    XX"
            " XX  XX "
            "  XXXX  "
            " XX  XX "
            "XX    XX"
            "XX    XX"
          end
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap do
            "XX    XX"
            "XX    XX"
            " XX  XX "
            "  XXXX  "
            "   XX   "
            "   XX   "
            "   XX   "
          end
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap do
            " XXXXXX "
            "     XX "
            "    XX  "
            "   XX   "
            "  XX    "
            " XX     "
            " XXXXXX "
          end
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap do
            "  XXXX  "
            "  XX    "
            "  XX    "
            "  XX    "
            "  XX    "
            "  XX    "
            "  XXXX  "
          end
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap do
            " XX     "
            " XX     "
            "  XX    "
            "   XX   "
            "    XX  "
            "     XX "
            "     XX "
          end
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap do
            "XXXX"
            "  XX"
            "  XX"
            "  XX"
            "  XX"
            "  XX"
            "XXXX"
          end
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap do
            "  XXX  "
            " XX XX "
            "XX   XX"
            "       "
            "       "
            "       "
            "       "
          end
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap do
            "        "
            "        "
            "        "
            "        "
            "        "
            "        "
            " XXXXXX "
          end
      },
      ?` => %{
        name: "grave accent",
        bitmap:
          defbitmap do
            "  XX    "
            "   XX   "
            "        "
            "        "
            "        "
            "        "
            "        "
          end
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXXX"
            "X   X"
            "X   X"
            "X   X"
            " XXXX"
          end
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap do
            "X    "
            "X    "
            "XXXX "
            "X   X"
            "X   X"
            "X   X"
            "XXXX "
          end
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXXX"
            "X    "
            "X    "
            "X    "
            " XXXX"
          end
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap do
            "    X"
            "    X"
            " XXXX"
            "X   X"
            "X   X"
            "X   X"
            " XXXX"
          end
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X    "
            " XXXX"
          end
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap do
            "  XX"
            " X  "
            " X  "
            "XXXX"
            " X  "
            " X  "
            " X  "
          end
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            " XXXX"
            "X   X"
            " XXXX"
            "    X"
            "XXXX "
          end
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap do
            "X    "
            "X    "
            "XXXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?i => %{
        name: "i",
        bitmap:
          defbitmap do
            "X"
            " "
            "X"
            "X"
            "X"
            "X"
            "X"
          end
      },
      ?j => %{
        name: "j",
        bitmap:
          defbitmap do
            "   X"
            "    "
            "   X"
            "   X"
            "   X"
            "X  X"
            " XX "
          end
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap do
            "X   "
            "X  X"
            "X X "
            "XX  "
            "X X "
            "X  X"
            "X  X"
          end
      },
      ?l => %{
        name: "l",
        bitmap:
          defbitmap do
            "X"
            "X"
            "X"
            "X"
            "X"
            "X"
            "X"
          end
      },
      ?m => %{
        name: "m",
        bitmap:
          defbitmap do
            "       "
            "       "
            "XXX XX "
            "X  X  X"
            "X  X  X"
            "X  X  X"
            "X  X  X"
          end
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap do
            "     "
            "     "
            "XXXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap do
            "     "
            "     "
            "XXXX "
            "X   X"
            "XXXX "
            "X    "
            "X    "
          end
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXXX"
            "X   X"
            " XXXX"
            "    X"
            "    X"
          end
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap do
            "    "
            "    "
            " XXX"
            "X   "
            "X   "
            "X   "
            "X   "
          end
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap do
            "     "
            "     "
            " XXXX"
            "X    "
            " XXX "
            "    X"
            "XXXX "
          end
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap do
            " X "
            " X "
            "XXX"
            " X "
            " X "
            " X "
            " X "
          end
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap do
            "     "
            "     "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap do
            "     "
            "     "
            "X   X"
            "X   X"
            "X   X"
            " X X "
            "  X  "
          end
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap do
            "       "
            "       "
            "X     X"
            "X     X"
            "X  X  X"
            "X  X  X"
            " XX XX "
          end
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap do
            "     "
            "     "
            "X   X"
            " X X "
            "  X  "
            " X X "
            "X   X"
          end
      },
      ?y => %{
        name: "y",
        bitmap:
          defbitmap do
            "     "
            "     "
            "X   X"
            "X   X"
            " XXXX"
            "    X"
            "XXXX "
          end
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap do
            "     "
            "     "
            "XXXXX"
            "   X "
            "  X  "
            " X   "
            "XXXXX"
          end
      },
      ?{ => %{
        name: "left curly brace",
        bitmap:
          defbitmap do
            "  X"
            " X "
            " X "
            "X  "
            " X "
            " X "
            "  X"
          end
      },
      ?| => %{
        name: "vertical bar",
        bitmap:
          defbitmap do
            "X"
            "X"
            "X"
            "X"
            "X"
            "X"
            "X"
          end
      },
      ?} => %{
        name: "right curly brace",
        bitmap:
          defbitmap do
            "X  "
            " X "
            " X "
            "  X"
            " X "
            " X "
            "X  "
          end
      },
      ?~ => %{
        name: "tilde",
        bitmap:
          defbitmap do
            "     "
            "     "
            " X   "
            "X X X"
            "   X "
            "     "
            "     "
          end
      },

      # ISO 8859-1 CHARACTERS

      160 => %{
        name: "no-break space",
        bitmap:
          defbitmap do
            " "
            " "
            " "
            " "
            " "
            " "
            " "
          end
      },
      ?¡ => %{
        name: "inverted exclamation mark",
        bitmap:
          defbitmap do
            "X"
            " "
            "X"
            "X"
            "X"
            "X"
            "X"
          end
      },
      ?¢ => %{
        name: "cent sign",
        bitmap:
          defbitmap do
            "     "
            "  XXX"
            " X   "
            "XXXX "
            " X   "
            "  XXX"
            "     "
          end
      },
      ?£ => %{
        name: "pound sign",
        bitmap:
          defbitmap do
            "  XXX"
            " X   "
            " X   "
            "XXXX "
            " X   "
            " X   "
            "XXXXX"
          end
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap do
            "     "
            "X   X"
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            " XXX "
            "X   X"
          end
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap do
            "X   X"
            " X X "
            "XXXXX"
            "  X  "
            "XXXXX"
            "  X  "
            "  X  "
          end
      },
      ?¦ => %{
        name: "broken bar",
        bitmap:
          defbitmap do
            "X"
            "X"
            "X"
            " "
            "X"
            "X"
            "X"
          end
      },
      ?§ => %{
        name: "section sign",
        bitmap:
          defbitmap baseline_y: -1 do
            " XXX "
            "X    "
            " X   "
            " XXX "
            "X   X"
            " XXX "
            "   X "
            "    X"
            " XXX "
          end
      },
      ?ß => %{
        name: "sharp s",
        bitmap:
          defbitmap baseline_y: -1 do
            " XXX "
            "X   X"
            "X  X "
            "X X  "
            "X  X "
            "X   X"
            "X XX "
            "X    "
          end
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap do
            "     "
            "X   X"
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?Á => %{
        name: "A with acute accent",
        bitmap:
          defbitmap do
            "   X "
            "  X  "
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?À => %{
        name: "A with grave accent",
        bitmap:
          defbitmap do
            " X   "
            "  X  "
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?Å => %{
        name: "A with ring",
        bitmap:
          defbitmap do
            " XXX "
            " XXX "
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?Ã => %{
        name: "A with tilde",
        bitmap:
          defbitmap do
            " XX X"
            "X XX "
            "     "
            " XXX "
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap do
            "X   X"
            "     "
            " XXXX"
            "X   X"
            "X   X"
            "X   X"
            " XXXX"
          end
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap do
            "X   X"
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap do
            " X X "
            "     "
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap do
            "X   X"
            "     "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap do
            " X X "
            "     "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?¨ => %{
        name: "diaresis",
        bitmap:
          defbitmap do
            "X X"
            "   "
            "   "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?© => %{
        name: "copyright sign",
        bitmap:
          defbitmap baseline_y: -1 do
            " XXX "
            "X   X"
            "  X  "
            " X X "
            " X   "
            " X X "
            "  X  "
            "X   X"
            " XXX "
          end
      },
      ?€ => %{
        name: "euro sign",
        bitmap:
          defbitmap do
            "  XXX"
            " X   "
            "XXXX "
            " X   "
            "XXXX "
            " X   "
            "  XXX"
          end
      },
      ?¯ => %{
        name: "macron",
        bitmap:
          defbitmap do
            "XXXXX"
            "     "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?° => %{
        name: "degree sign",
        bitmap:
          defbitmap do
            " X "
            "X X"
            " X "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?± => %{
        name: "plus-minus sign",
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "XXXXX"
            "  X  "
            "  X  "
            "     "
            "XXXXX"
          end
      },
      ?² => %{
        name: "superscript two",
        bitmap:
          defbitmap do
            "XX "
            "  X"
            " X "
            "X  "
            "XXX"
            "   "
            "   "
          end
      },
      ?³ => %{
        name: "superscript three",
        bitmap:
          defbitmap do
            "XX "
            "  X"
            " X "
            "  X"
            "XX "
            "   "
            "   "
          end
      },
      ?´ => %{
        name: "acute accent",
        bitmap:
          defbitmap baseline_y: 5 do
            " X"
            "X "
          end
      },
      ?µ => %{
        name: "micro sign",
        bitmap:
          defbitmap baseline_y: -1 do
            "    "
            "    "
            "    "
            "   X"
            "X  X"
            "X  X"
            "XXX "
            "X   "
            "X   "
          end
      },
      ?· => %{
        name: "middle dot",
        bitmap:
          defbitmap do
            " "
            " "
            " "
            "X"
            " "
            " "
            " "
          end
      },
      ?¹ => %{
        name: "superscript one",
        bitmap:
          defbitmap do
            " X "
            "XX "
            " X "
            " X "
            "XXX"
            "   "
            "   "
          end
      },
      ?ª => %{
        name: "feminine ordinal indicator",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "XXX"
            "X X"
            "   "
            "   "
            "   "
          end
      },
      ?º => %{
        name: "masculine ordinal indicator",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            " X "
            "   "
            "   "
            "   "
          end
      },
      ?« => %{
        name: "left-pointing double angle quotation mark",
        bitmap:
          defbitmap do
            "     "
            "     "
            " X X "
            "X X  "
            " X X "
            "     "
            "     "
          end
      },
      ?¬ => %{
        name: "not sign",
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            "XXXXX"
            "    X"
            "     "
            "     "
          end
      },
      ?» => %{
        name: "right-pointing double angle quotation mark",
        bitmap:
          defbitmap do
            "     "
            "     "
            " X X "
            "  X X"
            " X X "
            "     "
            "     "
          end
      },
      ?¼ => %{
        name: "vulgar fraction one quarter",
        bitmap:
          defbitmap do
            " X      X   "
            "XX     X    "
            " X    X X  X"
            " X   X  X  X"
            " X  X   XXXX"
            "   X       X"
            "  X        X"
          end
      },
      ?½ => %{
        name: "vulgar fraction one half",
        bitmap:
          defbitmap do
            " X      X   "
            "XX     X    "
            " X    X  XX "
            " X   X  X  X"
            " X  X     X "
            "   X     X  "
            "  X     XXXX"
          end
      },
      ?¾ => %{
        name: "vulgar fraction three quarters",
        bitmap:
          defbitmap do
            " XX      X    "
            "X  X    X     "
            "  X    X  X  X"
            "X  X  X   X  X"
            " XX  X    XXXX"
            "    X        X"
            "   X         X"
          end
      },
      ?¿ => %{
        name: "question mark",
        bitmap:
          defbitmap do
            "  X  "
            "     "
            "  X  "
            "  X  "
            "   X "
            "X   X"
            " XXX "
          end
      }
    }
  }

  def get, do: @font
end
