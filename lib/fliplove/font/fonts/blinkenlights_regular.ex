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
            " XXXX",
            "X X  ",
            " XXX ",
            "  X X",
            "XXXX ",
            "  X  "
          ])
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap([
            "XX  X",
            "XX  X",
            "   X ",
            "  X  ",
            " X   ",
            "X  XX",
            "X  XX"
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
            "X X X",
            "X  X ",
            " XX X"
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
            "     ",
            "X X X",
            " XXX ",
            "XXXXX",
            " XXX ",
            "X X X",
            "     "
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
          defbitmap(
            [
              " X",
              "X "
            ],
            baseline_y: -1
          )
      },
      ?- => %{
        name: "hyphen-minus",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "   ",
            "XXX",
            "   ",
            "   ",
            "   "
          ])
      },
      ?. => %{
        name: "full stop",
        bitmap:
          defbitmap([
            "X"
          ])
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap([
            "    X",
            "    X",
            "   X ",
            "  X  ",
            " X   ",
            "X    ",
            "X    "
          ])
      },
      ?0 => %{
        name: "zero",
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
            "   X ",
            "  X  ",
            " X   ",
            "X    ",
            "XXXXX"
          ])
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "    X",
            "   X ",
            "    X",
            "X   X",
            " XXX "
          ])
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap([
            "X    ",
            "X   X",
            "X   X",
            "XXXXX",
            "    X",
            "    X",
            "    X"
          ])
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap([
            "XXXXX",
            "X    ",
            "XXXX ",
            "    X",
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
            "  X  ",
            "  X  ",
            "  X  "
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
            "X",
            " ",
            " "
          ])
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap([
            "  ",
            " X",
            "  ",
            " X",
            " X",
            "X "
          ])
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap([
            "    ",
            "  X ",
            " X  ",
            "X   ",
            " X  ",
            "  X ",
            "    "
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
            "    ",
            " X  ",
            "  X ",
            "   X",
            "  X ",
            " X  ",
            "    "
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
            "  XXXXXX  ",
            " X      X ",
            "X  XX X  X",
            "X X  XX  X",
            "X  XX XXX ",
            " X        ",
            "  XXXXXX  "
          ])
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap([
            " XXX ",
            "X   X",
            "X   X",
            "XXXXX",
            "X   X",
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
            " XXXX",
            "X    ",
            "X    ",
            "X    ",
            "X    ",
            "X    ",
            " XXXX"
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
            "XXX  ",
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
            "XXX  ",
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
            "X   X",
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
            "X   X",
            "X  X ",
            " XX X"
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
            "X   X",
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
            "XXX",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap([
            "X    ",
            "X    ",
            " X   ",
            "  X  ",
            "   X ",
            "    X",
            "    X"
          ])
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap([
            "XXX",
            "  X",
            "  X",
            "  X",
            "  X",
            "  X",
            "XXX"
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
            "XXXXX"
          ])
      },
      ?` => %{
        name: "apostrophe",
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
            "XXXX ",
            "X    ",
            "X    "
          ])
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap([
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
            " XXXX",
            "    X",
            "XXXX "
          ])
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap([
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
              " XXX ",
              "X   X",
              "X  X ",
              "X X  ",
              "X  X ",
              "X   X",
              "X XX ",
              "X    "
            ],
            baseline_y: -1
          )
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
        name: "A with acute",
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
        name: "A with grave",
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
            "     ",
            " XXX ",
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
