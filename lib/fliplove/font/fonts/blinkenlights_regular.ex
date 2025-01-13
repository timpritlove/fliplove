defmodule Fliplove.Font.Fonts.BlinkenLightsRegular do
  alias Fliplove.Bitmap
  import Bitmap
  alias Fliplove.Font

  @font %Font{
    name: "blinkenlights-regular",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Blinkenlights",
      foundry: "BBB",
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
            "   "
            "   "
            "   "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?! => %{
        name: "exclamation mark",
        bitmap:
          defbitmap do
            "X"
            "X"
            "X"
            "X"
            "X"
            " "
            "X"
          end
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "   "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap do
            " X X "
            " X X "
            "XXXXX"
            " X X "
            "XXXXX"
            " X X "
            " X X "
          end
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap do
            "  X  "
            " XXXX"
            "X X  "
            " XXX "
            "  X X"
            "XXXX "
            "  X  "
          end
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap do
            "XX  X"
            "XX  X"
            "   X "
            "  X  "
            " X   "
            "X  XX"
            "X  XX"
          end
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap do
            " XX  "
            "X  X "
            "X  X "
            " XX  "
            "X X X"
            "X  X "
            " XX X"
          end
      },
      ?' => %{
        name: "apostrophe",
        bitmap:
          defbitmap do
            "X"
            "X"
            " "
            " "
            " "
            " "
            " "
          end
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap do
            "  X"
            " X "
            "X  "
            "X  "
            "X  "
            " X "
            "  X"
          end
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap do
            "X  "
            " X "
            "  X"
            "  X"
            "  X"
            " X "
            "X  "
          end
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap do
            "     "
            "X X X"
            " XXX "
            "XXXXX"
            " XXX "
            "X X X"
            "     "
          end
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap do
            "     "
            "  X  "
            "  X  "
            "XXXXX"
            "  X  "
            "  X  "
            "     "
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
            "   "
            "   "
            "   "
            "XXX"
            "   "
            "   "
            "   "
          end
      },
      ?. => %{
        name: "full stop",
        bitmap:
          defbitmap do
            "X"
          end
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap do
            "    X"
            "    X"
            "   X "
            "  X  "
            " X   "
            "X    "
            "X    "
          end
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap do
            " X "
            "XX "
            " X "
            " X "
            " X "
            " X "
            "XXX"
          end
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "   X "
            "  X  "
            " X   "
            "X    "
            "XXXXX"
          end
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "    X"
            "   X "
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap do
            "X    "
            "X   X"
            "X   X"
            "XXXXX"
            "    X"
            "    X"
            "    X"
          end
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "XXXX "
            "    X"
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X    "
            "XXXX "
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap do
            "XXXXX"
            "    X"
            "   X "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            " XXX "
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            " XXXX"
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap do
            " "
            "X"
            " "
            "X"
            " "
            " "
          end
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap do
            "  "
            " X"
            "  "
            " X"
            " X"
            "X "
          end
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap do
            "    "
            "  X "
            " X  "
            "X   "
            " X  "
            "  X "
            "    "
          end
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap do
            "     "
            "     "
            "XXXXX"
            "     "
            "XXXXX"
            "     "
            "     "
          end
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap do
            "    "
            " X  "
            "  X "
            "   X"
            "  X "
            " X  "
            "    "
          end
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "   X "
            "  X  "
            "  X  "
            "     "
            "  X  "
          end
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap do
            "  XXXXXX  "
            " X      X "
            "X  XX X  X"
            "X X  XX  X"
            "X  XX XXX "
            " X        "
            "  XXXXXX  "
          end
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap do
            "XXXX "
            "X   X"
            "X   X"
            "XXXX "
            "X   X"
            "X   X"
            "XXXX "
          end
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap do
            " XXXX"
            "X    "
            "X    "
            "X    "
            "X    "
            "X    "
            " XXXX"
          end
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap do
            "XXXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "XXXX "
          end
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXX  "
            "X    "
            "X    "
            "XXXXX"
          end
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXX  "
            "X    "
            "X    "
            "X    "
          end
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X    "
            "X XXX"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap do
            "XXX"
            " X "
            " X "
            " X "
            " X "
            " X "
            "XXX"
          end
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap do
            "    X"
            "    X"
            "    X"
            "    X"
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap do
            "X   X"
            "X  X "
            "X X  "
            "XX   "
            "X X  "
            "X  X "
            "X   X"
          end
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap do
            "X    "
            "X    "
            "X    "
            "X    "
            "X    "
            "X    "
            "XXXXX"
          end
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap do
            "X   X"
            "XX XX"
            "X X X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "XX  X"
            "X X X"
            "X  XX"
            "X   X"
            "X   X"
          end
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap do
            "XXXX "
            "X   X"
            "X   X"
            "XXXX "
            "X    "
            "X    "
            "X    "
          end
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X  X "
            " XX X"
          end
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap do
            "XXXX "
            "X   X"
            "X   X"
            "XXXX "
            "X X  "
            "X  X "
            "X   X"
          end
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X    "
            " XXX "
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap do
            "XXXXX"
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            " X X "
            "  X  "
          end
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "X   X"
            "X X X"
            "XX XX"
            "X   X"
          end
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            " X X "
            "  X  "
            " X X "
            "X   X"
            "X   X"
          end
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
            "  XX  "
            "  XX  "
            "  XX  "
          end
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap do
            "XXXXXX"
            "    XX"
            "   XX "
            "  XX  "
            " XX   "
            "XX    "
            "XXXXXX"
          end
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap do
            "XXX"
            "X  "
            "X  "
            "X  "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap do
            "X    "
            "X    "
            " X   "
            "  X  "
            "   X "
            "    X"
            "    X"
          end
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap do
            "XXX"
            "  X"
            "  X"
            "  X"
            "  X"
            "  X"
            "XXX"
          end
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            "X   X"
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap do
            "XXXXX"
          end
      },
      ?` => %{
        name: "apostrophe",
        bitmap:
          defbitmap do
            "X "
            " X"
            "  "
            "  "
            "  "
            "  "
            "  "
          end
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap do
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
        name: "A with acute",
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
        name: "A with grave",
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
            "     "
            " XXX "
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

  def get(), do: @font
end
