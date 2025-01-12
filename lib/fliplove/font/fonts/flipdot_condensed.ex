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
          defbitmap do
            "XXX"
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
          end
      },
      ?\s => %{
        name: "space",
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
            " X "
            " X "
            "XXX"
            " X "
            "XXX"
            " X "
            " X "
          end
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap do
              " X "
              "XXX"
              "X  "
              "XXX"
              "  X"
              "XXX"
              " X "
            end
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "  X"
            " X "
            "X  "
            "X X"
            "X X"
          end
      },
      ?& => %{
        name: "ampersand",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            " X "
            "X  "
            "X X"
            " XX"
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
            "   "
            "   "
            "X X"
            " X "
            "X X"
            "   "
            "   "
          end
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap do
            "   "
            "   "
            " X "
            "XXX"
            " X "
            "   "
            "   "
          end
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap baseline_y: -1 do
              "X"
              "X"
            end
      },
      ?- => %{
        name: "hyphen",
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
        name: "period",
        bitmap:
          defbitmap do
            "X"
          end
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap do
            "  X"
            "  X"
            " X "
            " X "
            " X "
            "X  "
            "X  "
          end
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            " X "
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
            " X "
            "X X"
            "  X"
            " X "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "  X"
            " X "
            "  X"
            "X X"
            " X "
          end
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap do
            "X  "
            "X X"
            "X X"
            "XXX"
            "  X"
            "  X"
            "  X"
          end
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap do
            "XXX"
            "X  "
            "XX "
            "  X"
            "  X"
            "X X"
            " X "
          end
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X  "
            "XX "
            "X X"
            "X X"
            " X "
          end
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap do
            "XXX"
            "  X"
            "  X"
            " X "
            " X "
            " X "
            " X "
          end
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            " X "
            "X X"
            "X X"
            " X "
          end
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            " XX"
            "  X"
            "X X"
            " X "
          end
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap do
            " "
            "X"
            " "
            " "
            "X"
            " "
          end
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap baseline_y: -1 do
              " "
              " "
              "X"
              " "
              "X"
              "X"
            end
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap do
            "   "
            "  X"
            " X "
            "X  "
            " X "
            "  X"
            "   "
          end
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap do
            "   "
            "   "
            "XXX"
            "   "
            "XXX"
            "   "
            "   "
          end
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap do
            "   "
            "X  "
            " X "
            "  X"
            " X "
            "X  "
            "   "
          end
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "  X"
            " X "
            " X "
            "   "
            " X "
          end
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap do
            " XX"
            "X X"
            "X X"
            "X X"
            "X  "
            "X  "
            " XX"
          end
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            "X X"
            "XXX"
            "X X"
            "X X"
          end
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap do
            "XX "
            "X X"
            "X X"
            "XX "
            "X X"
            "X X"
            "XX "
          end
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap do
            " XX"
            "X  "
            "X  "
            "X  "
            "X  "
            "X  "
            " XX"
          end
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap do
            "XX "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "XX "
          end
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap do
            "XXX"
            "X  "
            "X  "
            "XX "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap do
            "XXX"
            "X  "
            "X  "
            "XX "
            "X  "
            "X  "
            "X  "
          end
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X  "
            "X X"
            "X X"
            "X X"
            " XX"
          end
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            "XXX"
            "X X"
            "X X"
            "X X"
          end
      },
      ?I => %{
        name: "I",
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
      ?J => %{
        name: "J",
        bitmap:
          defbitmap do
            "  X"
            "  X"
            "  X"
            "  X"
            "  X"
            "X X"
            " X "
          end
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            "XX "
            "X X"
            "X X"
            "X X"
          end
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap do
            "X  "
            "X  "
            "X  "
            "X  "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap do
            "X X"
            "XXX"
            "XXX"
            "X X"
            "X X"
            "X X"
            "X X"
          end
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap do
            "XX "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
          end
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap do
            "XX "
            "X X"
            "X X"
            "XX "
            "X  "
            "X  "
            "X  "
          end
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X X"
            "X X"
            "X X"
            "XX "
            " XX"
          end
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap do
            "XX "
            "X X"
            "X X"
            "XX "
            "X X"
            "X X"
            "X X"
          end
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "X  "
            " X "
            "  X"
            "X X"
            " X "
          end
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap do
            "XXX"
            " X "
            " X "
            " X "
            " X "
            " X "
            " X "
          end
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
          end
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
            "XXX"
            "X X"
          end
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            " X "
            "X X"
            "X X"
            "X X"
          end
      },
      ?Y => %{
        name: "Y",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "X X"
            " X "
            " X "
            " X "
            " X "
          end
      },
      ?Z => %{
        name: "Z",
        bitmap:
          defbitmap do
            "XXX"
            "  X"
            "  X"
            " X "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?[ => %{
        name: "left square bracket",
        bitmap:
          defbitmap do
            "XX"
            "X "
            "X "
            "X "
            "X "
            "X "
            "XX"
          end
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap do
            "X  "
            "X  "
            " X "
            " X "
            " X "
            "  X"
            "  X"
          end
      },
      ?] => %{
        name: "right square bracket",
        bitmap:
          defbitmap do
            "XX"
            " X"
            " X"
            " X"
            " X"
            " X"
            "XX"
          end
      },
      ?^ => %{
        name: "caret",
        bitmap:
          defbitmap do
            " X "
            "X X"
            "   "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?_ => %{
        name: "underscore",
        bitmap:
          defbitmap do
            "   "
            "   "
            "   "
            "   "
            "   "
            "   "
            "XXX"
          end
      },
      ?` => %{
        name: "grave accent",
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
            "   "
            "   "
            "XX "
            "  X"
            " XX"
            "X X"
            "XXX"
          end
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap do
            "X  "
            "X  "
            "XX "
            "X X"
            "X X"
            "X X"
            "XX "
          end
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap do
            "   "
            "   "
            " XX"
            "X  "
            "X  "
            "X  "
            " XX"
          end
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap do
            "  X"
            "  X"
            " XX"
            "X X"
            "X X"
            "X X"
            " XX"
          end
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap do
            "   "
            "   "
            " X "
            "X X"
            "XXX"
            "X  "
            " XX"
          end
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap do
            " X"
            "X "
            "X "
            "XX"
            "X "
            "X "
            "X "
          end
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap baseline_y: -2 do
            "   "
            " X "
            "X X"
            "X X"
            "X X"
            " XX"
            "  X"
            " XX"
            end
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap do
            "X  "
            "X  "
            "XX "
            "X X"
            "X X"
            "X X"
            "X X"
          end
      },
      ?ï => %{
        name: "i diaeresis",
        bitmap:
          defbitmap do
            "X"
            " "
            "X"
            " "
            "X"
            "X"
            "X"
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
          defbitmap baseline_y: -2 do
              " X"
              "  "
              " X"
              " X"
              " X"
              " X"
              " X"
              "X "
            end
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap do
            "X  "
            "X  "
            "X X"
            "XX "
            "XX "
            "X X"
            "X X"
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
            "   "
            "   "
            "XXX"
            "XXX"
            "X X"
            "X X"
            "X X"
          end
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap do
            "   "
            "   "
            "XX "
            "X X"
            "X X"
            "X X"
            "X X"
          end
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap do
            "   "
            "   "
            " X "
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap baseline_y: -2 do
              "XX "
              "X X"
              "X X"
              "X X"
              "XX "
              "X  "
              "X  "
            end
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap baseline_y: -2 do
              " X "
              "X X"
              "X X"
              "X X"
              " XX"
              "  X"
              "  X"
            end
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap do
            "  "
            "  "
            " X"
            "X "
            "X "
            "X "
            "X "
          end
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap do
            "   "
            "   "
            " XX"
            "X  "
            " X "
            "  X"
            "XX "
          end
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap do
            "X "
            "X "
            "XX"
            "X "
            "X "
            "X "
            " X"
          end
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap do
            "   "
            "   "
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
          end
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap do
            "   "
            "   "
            "X X"
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap do
            "   "
            "   "
            "X X"
            "X X"
            "XXX"
            "XXX"
            "X X"
          end
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap do
            "   "
            "   "
            "X X"
            "X X"
            " X "
            "X X"
            "X X"
          end
      },
      ?y => %{
        name: "y",
        bitmap:
        defbitmap baseline_y: -2 do
          "   "
          "X X"
          "X X"
          "X X"
          "X X"
          " XX"
          "  X"
          "XX "
        end
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap do
            "   "
            "   "
            "XXX"
            "  X"
            " X "
            "X  "
            "XXX"
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
            "    "
            "    "
            " X X"
            "X X "
            "    "
            "    "
            "    "
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
            " XX"
            "X  "
            "X  "
            "XX "
            "X  "
            "X  "
            "XXX"
          end
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap do
            "   "
            "X X"
            " X "
            "X X"
            "X X"
            "X X"
            " X "
            "X X"
          end
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap do
            "X X"
            "X X"
            "XXX"
            " X "
            "XXX"
            " X "
            " X "
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
              " X "
              "X  "
              " X "
              " X "
              "X X"
              " X "
              " X "
              "  X"
              " X "
            end
      },
      ?ß => %{
        name: "sharp s",
        bitmap:
          defbitmap baseline_y: -1 do
              " X "
              "X X"
              "X X"
              "XX "
              "X X"
              "X X"
              "XX "
              "X  "
            end
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap do
            "X X"
            " X "
            "X X"
            "X X"
            "X X"
            "XXX"
            "X X"
            "X X"
          end
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap do
            "X X"
            "   "
            "XX "
            "  X"
            " XX"
            "X X"
            "XXX"
          end
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap do
            "X X"
            " X "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap do
            "X X"
            "   "
            " X "
            "X X"
            "X X"
            "X X"
            " X "
          end
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap do
            "X X"
            "   "
            "X X"
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
          end
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap do
            "X X"
            "   "
            "X X"
            "X X"
            "X X"
            "X X"
            "XXX"
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
              " X "
              "X X"
              "   "
              " XX"
              "X  "
              " XX"
              "   "
              "X X"
              " X "
            end
      },
      ?€ => %{
        name: "euro sign",
        bitmap:
          defbitmap do
            " XX"
            "X  "
            "XX "
            "X  "
            "XX "
            "X  "
            " XX"
          end
      },
      ?¯ => %{
        name: "macron",
        bitmap:
          defbitmap do
            "XXX"
            "   "
            "   "
            "   "
            "   "
            "   "
            "   "
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
            "   "
            " X "
            "XXX"
            " X "
            "   "
            "XXX"
            "   "
          end
      },
      ?² => %{
        name: "superscript two",
        bitmap:
          defbitmap do
            "X "
            " X"
            "X "
            "X "
            "XX"
            "  "
            "  "
          end
      },
      ?³ => %{
        name: "superscript three",
        bitmap:
          defbitmap do
            "X "
            " X"
            "X "
            " X"
            "X "
            "  "
            "  "
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
              "   "
              "   "
              "   "
              "  X"
              "X X"
              "X X"
              "XX "
              "X  "
              "X  "
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
            " X"
            "XX"
            " X"
            " X"
            " X"
            "  "
            "  "
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
            "    "
            "    "
            " X X"
            "X X "
            " X X"
            "    "
            "    "
          end
      },
      ?¬ => %{
        name: "not sign",
        bitmap:
          defbitmap do
            "   "
            "   "
            "   "
            "XXX"
            "  X"
            "   "
            "   "
          end
      },
      ?» => %{
        name: "right-pointing double angle quotation mark",
        bitmap:
          defbitmap do
            "    "
            "    "
            "X X "
            " X X"
            "X X "
            "    "
            "    "
          end
      },
      ?¼ => %{
        name: "vulgar fraction one quarter",
        bitmap:
          defbitmap do
            " X "
            " X "
            " X "
            "   "
            "X X"
            "XXX"
            "  X"
          end
      },
      ?½ => %{
        name: "vulgar fraction one half",
        bitmap:
          defbitmap do
            " X "
            " X "
            " X "
            "   "
            "XX "
            " X "
            " XX"
          end
      },
      ?¾ => %{
        name: "vulgar fraction three quarters",
        bitmap:
          defbitmap do
            "XX "
            " XX"
            "XX "
            "   "
            "X X"
            "XXX"
            "  X"
          end
      },
      ?¿ => %{
        name: "inverted question mark",
        bitmap:
          defbitmap do
            " X "
            "   "
            " X "
            " X "
            "  X"
            "X X"
            " X "
          end
      }
    }
  }

  def get(), do: @font
end
