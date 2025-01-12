defmodule Fliplove.Font.Fonts.FlipdotCondensed do
  alias Fliplove.Bitmap
  import Bitmap
  alias Fliplove.Font

  @font %Font{
    name: "flipdot_condensed",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Flipdot",
      foundry: "AAA",
      weight_name: "Condensed",
      slant: "R",
      pixel_size: 7
    },
    characters: %{
      0 => %{
        name: "defaultchar",
        bitmap:
          defbitmap([
            "XXX",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX"
          ])
      },
      ?\s => %{
        name: "space",
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
            " X ",
            " X ",
            "XXX",
            " X ",
            "XXX",
            " X ",
            " X "
          ])
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap(
            [
              " X ",
              "XXX",
              "X  ",
              "XXX",
              "  X",
              "XXX",
              " X "
            ],
            baseline_y: 0
          )
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "  X",
            " X ",
            "X  ",
            "X X",
            "X X"
          ])
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            " X ",
            "X  ",
            "X X",
            " XX"
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
            "   ",
            "   ",
            "X X",
            " X ",
            "X X",
            "   ",
            "   "
          ])
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            " X ",
            "XXX",
            " X ",
            "   ",
            "   "
          ])
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap(
            [
              "X",
              "X"
            ],
            baseline_y: -1
          )
      },
      ?- => %{
        name: "hyphen",
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
            " X ",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            " X "
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
            " X ",
            "X X",
            "  X",
            " X ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "  X",
            " X ",
            "  X",
            "X X",
            " X "
          ])
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap([
            "X  ",
            "X X",
            "X X",
            "XXX",
            "  X",
            "  X",
            "  X"
          ])
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap([
            "XXX",
            "X  ",
            "XX ",
            "  X",
            "  X",
            "X X",
            " X "
          ])
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X  ",
            "XX ",
            "X X",
            "X X",
            " X "
          ])
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap([
            "XXX",
            "  X",
            "  X",
            " X ",
            " X ",
            " X ",
            " X "
          ])
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            " X ",
            "X X",
            "X X",
            " X "
          ])
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            " XX",
            "  X",
            "X X",
            " X "
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
            "X",
            " "
          ])
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap(
            [
              " ",
              " ",
              "X",
              " ",
              "X",
              "X"
            ],
            baseline_y: -1
          )
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap([
            "   ",
            "  X",
            " X ",
            "X  ",
            " X ",
            "  X",
            "   "
          ])
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "XXX",
            "   ",
            "XXX",
            "   ",
            "   "
          ])
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap([
            "   ",
            "X  ",
            " X ",
            "  X",
            " X ",
            "X  ",
            "   "
          ])
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "  X",
            " X ",
            " X ",
            "   ",
            " X "
          ])
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap([
            " XX",
            "X X",
            "X X",
            "X X",
            "X  ",
            "X  ",
            " XX"
          ])
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            "X X",
            "XXX",
            "X X",
            "X X"
          ])
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap([
            "XX ",
            "X X",
            "X X",
            "XX ",
            "X X",
            "X X",
            "XX "
          ])
      },
      ?C => %{
        name: "C",
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
      ?D => %{
        name: "D",
        bitmap:
          defbitmap([
            "XX ",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "XX "
          ])
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap([
            "XXX",
            "X  ",
            "X  ",
            "XX ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap([
            "XXX",
            "X  ",
            "X  ",
            "XX ",
            "X  ",
            "X  ",
            "X  "
          ])
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X  ",
            "X X",
            "X X",
            "X X",
            " XX"
          ])
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            "XXX",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?I => %{
        name: "I",
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
      ?J => %{
        name: "J",
        bitmap:
          defbitmap([
            "  X",
            "  X",
            "  X",
            "  X",
            "  X",
            "X X",
            " X "
          ])
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            "XX ",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap([
            "X X",
            "XXX",
            "XXX",
            "X X",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "XXX",
            "X X",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap([
            "XX ",
            "X X",
            "X X",
            "XX ",
            "X  ",
            "X  ",
            "X  "
          ])
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X X",
            "X X",
            "X X",
            "XX ",
            " XX"
          ])
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap([
            "XX ",
            "X X",
            "X X",
            "XX ",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "X  ",
            " X ",
            "  X",
            "X X",
            " X "
          ])
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap([
            "XXX",
            " X ",
            " X ",
            " X ",
            " X ",
            " X ",
            " X "
          ])
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX"
          ])
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX",
            "XXX",
            "X X"
          ])
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            " X ",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "X X",
            " X ",
            " X ",
            " X ",
            " X "
          ])
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap([
            "XXX",
            "  X",
            "  X",
            " X ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap([
            "XX",
            "X ",
            "X ",
            "X ",
            "X ",
            "X ",
            "XX"
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
            "XX",
            " X",
            " X",
            " X",
            " X",
            " X",
            "XX"
          ])
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap([
            " X ",
            "X X",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
          ])
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "XXX"
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
            "   ",
            "   ",
            "XX ",
            "  X",
            " XX",
            "X X",
            "XXX"
          ])
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            "XX ",
            "X X",
            "X X",
            "X X",
            "XX "
          ])
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            " XX",
            "X  ",
            "X  ",
            "X  ",
            " XX"
          ])
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap([
            "  X",
            "  X",
            " XX",
            "X X",
            "X X",
            "X X",
            " XX"
          ])
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            " X ",
            "X X",
            "XXX",
            "X  ",
            " XX"
          ])
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap([
            " X",
            "X ",
            "X ",
            "XX",
            "X ",
            "X ",
            "X "
          ])
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap([
            "   ",
            " X ",
            "X X",
            "X X",
            "X X",
            " XX",
            "  X",
            " XX"
            ],
            baseline_y: -2
          )
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            "XX ",
            "X X",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?ï => %{
        name: "i diaeresis",
        bitmap:
          defbitmap([
            "X",
            " ",
            "X",
            " ",
            "X",
            "X",
            "X"
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
          defbitmap(
            [
              " X",
              "  ",
              " X",
              " X",
              " X",
              " X",
              " X",
              "X "
            ],
            baseline_y: -2
          )
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap([
            "X  ",
            "X  ",
            "X X",
            "XX ",
            "XX ",
            "X X",
            "X X"
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
            "   ",
            "   ",
            "XXX",
            "XXX",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "XX ",
            "X X",
            "X X",
            "X X",
            "X X"
          ])
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            " X ",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap(
            [
              "XX ",
              "X X",
              "X X",
              "X X",
              "XX ",
              "X  ",
              "X  "
            ],
            baseline_y: -2
          )
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap(
            [
              " X ",
              "X X",
              "X X",
              "X X",
              " XX",
              "  X",
              "  X"
            ],
            baseline_y: -2
          )
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap([
            "  ",
            "  ",
            " X",
            "X ",
            "X ",
            "X ",
            "X "
          ])
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            " XX",
            "X  ",
            " X ",
            "  X",
            "XX "
          ])
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap([
            "X ",
            "X ",
            "XX",
            "X ",
            "X ",
            "X ",
            " X"
          ])
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX"
          ])
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "X X",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "X X",
            "X X",
            "XXX",
            "XXX",
            "X X"
          ])
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "X X",
            "X X",
            " X ",
            "X X",
            "X X"
          ])
      },
      ?y => %{
        name: "y",
        bitmap:
        defbitmap([
          "   ",
          "X X",
          "X X",
          "X X",
          "X X",
          " XX",
          "  X",
          "XX "
          ],
          baseline_y: -2
        )
    },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "XXX",
            "  X",
            " X ",
            "X  ",
            "XXX"
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
            " XX",
            "X  ",
            "X  ",
            "XX ",
            "X  ",
            "X  ",
            "XXX"
          ])
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap([
            "   ",
            "X X",
            " X ",
            "X X",
            "X X",
            "X X",
            " X ",
            "X X"
          ])
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap([
            "X X",
            "X X",
            "XXX",
            " X ",
            "XXX",
            " X ",
            " X "
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
              " X ",
              "X  ",
              " X ",
              " X ",
              "X X",
              " X ",
              " X ",
              "  X",
              " X "
            ],
            baseline_y: -1
          )
      },
      ?ß => %{
        name: "sharp s",
        bitmap:
          defbitmap(
            [
              " X ",
              "X X",
              "X X",
              "XX ",
              "X X",
              "X X",
              "XX ",
              "X  "
            ],
            baseline_y: -1
          )
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap([
            "X X",
            " X ",
            "X X",
            "X X",
            "X X",
            "XXX",
            "X X",
            "X X"
          ])
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            "XX ",
            "  X",
            " XX",
            "X X",
            "XXX"
          ])
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap([
            "X X",
            " X ",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            " X ",
            "X X",
            "X X",
            "X X",
            " X "
          ])
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            "X X",
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX"
          ])
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap([
            "X X",
            "   ",
            "X X",
            "X X",
            "X X",
            "X X",
            "XXX"
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
              " X ",
              "X X",
              "   ",
              " XX",
              "X  ",
              " XX",
              "   ",
              "X X",
              " X "
            ],
            baseline_y: -1
          )
      },
      ?€ => %{
        name: "euro sign",
        bitmap:
          defbitmap([
            " XX",
            "X  ",
            "XX ",
            "X  ",
            "XX ",
            "X  ",
            " XX"
          ])
      },
      ?¯ => %{
        name: "macron",
        bitmap:
          defbitmap([
            "XXX",
            "   ",
            "   ",
            "   ",
            "   ",
            "   ",
            "   "
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
            "   ",
            " X ",
            "XXX",
            " X ",
            "   ",
            "XXX",
            "   "
          ])
      },
      ?² => %{
        name: "superscript two",
        bitmap:
          defbitmap([
            "X ",
            " X",
            "X ",
            "X ",
            "XX",
            "  ",
            "  "
          ])
      },
      ?³ => %{
        name: "superscript three",
        bitmap:
          defbitmap([
            "X ",
            " X",
            "X ",
            " X",
            "X ",
            "  ",
            "  "
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
              "   ",
              "   ",
              "   ",
              "  X",
              "X X",
              "X X",
              "XX ",
              "X  ",
              "X  "
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
            " X",
            "XX",
            " X",
            " X",
            " X",
            "  ",
            "  "
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
            "    ",
            "    ",
            " X X",
            "X X ",
            " X X",
            "    ",
            "    "
          ])
      },
      ?¬ => %{
        name: "not sign",
        bitmap:
          defbitmap([
            "   ",
            "   ",
            "   ",
            "XXX",
            "  X",
            "   ",
            "   "
          ])
      },
      ?» => %{
        name: "right-pointing double angle quotation mark",
        bitmap:
          defbitmap([
            "    ",
            "    ",
            "X X ",
            " X X",
            "X X ",
            "    ",
            "    "
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
        name: "inverted question mark",
        bitmap:
          defbitmap([
            " X ",
            "   ",
            " X ",
            " X ",
            "  X",
            "X X",
            " X "
          ])
      }
    }
  }

  def get(), do: @font
end
