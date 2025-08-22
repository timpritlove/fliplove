defmodule Fliplove.Font.Fonts.BlinkenlightsBold do
  @moduledoc """
  Blinkenlights Bold bitmap font data.

  This module contains the bitmap font data for the "Blinkenlights Bold" font,
  a bold variant inspired by classic LED matrix display typography.
  """
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
          defbitmap do
            "XXXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XXXXXX"
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
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
            "  "
            "XX"
          end
      },
      ?" => %{
        name: "quotation mark",
        bitmap:
          defbitmap do
            "XX XX"
            "XX XX"
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?# => %{
        name: "number sign",
        bitmap:
          defbitmap do
            " XX XX "
            " XX XX "
            "XXXXXXX"
            " XX XX "
            "XXXXXXX"
            " XX XX "
            " XX XX "
          end
      },
      ?$ => %{
        name: "dollar sign",
        bitmap:
          defbitmap do
            "   XX   "
            "  XXXXXX"
            "XX XX   "
            "  XXXX  "
            "   XX XX"
            "XXXXXX  "
            "   XX   "
          end
      },
      ?% => %{
        name: "percent sign",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "   XX "
            "  XX  "
            " XX   "
            "XX  XX"
            "XX  XX"
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
            "XX"
            "XX"
            "  "
            "  "
            "  "
            "  "
            "  "
          end
      },
      ?( => %{
        name: "left parenthesis",
        bitmap:
          defbitmap do
            "  XX"
            " XX "
            "XX  "
            "XX  "
            "XX  "
            " XX "
            "  XX"
          end
      },
      ?) => %{
        name: "right parenthesis",
        bitmap:
          defbitmap do
            "XX  "
            " XX "
            "  XX"
            "  XX"
            "  XX"
            " XX "
            "XX  "
          end
      },
      ?* => %{
        name: "asterisk",
        bitmap:
          defbitmap do
            "       "
            "XX X XX"
            " XXXXX "
            "XXXXXXX"
            " XXXXX "
            "XX X XX"
            "       "
          end
      },
      ?+ => %{
        name: "plus sign",
        bitmap:
          defbitmap do
            "      "
            "  XX  "
            "  XX  "
            "XXXXXX"
            "  XX  "
            "  XX  "
            "      "
          end
      },
      ?, => %{
        name: "comma",
        bitmap:
          defbitmap baseline_y: -1 do
            " XX"
            "XX "
          end
      },
      ?- => %{
        name: "hyphen",
        bitmap:
          defbitmap do
            "XXXX"
            "    "
            "    "
            "    "
          end
      },
      ?. => %{
        name: "period",
        bitmap:
          defbitmap do
            "XX"
          end
      },
      ?/ => %{
        name: "slash",
        bitmap:
          defbitmap do
            "    XX"
            "    XX"
            "   XX "
            "  XX  "
            " XX   "
            "XX    "
            "XX    "
          end
      },
      ?0 => %{
        name: "zero",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?1 => %{
        name: "one",
        bitmap:
          defbitmap do
            " XX "
            "XXX "
            " XX "
            " XX "
            " XX "
            " XX "
            "XXXX"
          end
      },
      ?2 => %{
        name: "two",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "   XX "
            "  XX  "
            " XX   "
            "XX    "
            "XXXXXX"
          end
      },
      ?3 => %{
        name: "three",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "    XX"
            "   XX "
            "    XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?4 => %{
        name: "four",
        bitmap:
          defbitmap do
            "XX    "
            "XX  XX"
            "XX  XX"
            "XXXXXX"
            "    XX"
            "    XX"
            "    XX"
          end
      },
      ?5 => %{
        name: "five",
        bitmap:
          defbitmap do
            "XXXXXX"
            "XX    "
            "XXXXX "
            "    XX"
            "    XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?6 => %{
        name: "six",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX    "
            "XXXXX "
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?7 => %{
        name: "seven",
        bitmap:
          defbitmap do
            "XXXXXX"
            "    XX"
            "   XX "
            "  XX  "
            "  XX  "
            "  XX  "
            "  XX  "
          end
      },
      ?8 => %{
        name: "eight",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            " XXXX "
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?9 => %{
        name: "nine",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            " XXXXX"
            "    XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?: => %{
        name: "colon",
        bitmap:
          defbitmap do
            "XX"
            "  "
            "XX"
            "  "
            "  "
          end
      },
      ?; => %{
        name: "semicolon",
        bitmap:
          defbitmap do
            " XX"
            "   "
            " XX"
            " XX"
            "XX "
          end
      },
      ?< => %{
        name: "less-than sign",
        bitmap:
          defbitmap do
            "     "
            "  XX "
            " XX  "
            "XX   "
            " XX  "
            "  XX "
            "     "
          end
      },
      ?= => %{
        name: "equals sign",
        bitmap:
          defbitmap do
            "XXXXXX"
            "      "
            "XXXXXX"
            "      "
            "      "
          end
      },
      ?> => %{
        name: "greater-than sign",
        bitmap:
          defbitmap do
            "     "
            " XX  "
            "  XX "
            "   XX"
            "  XX "
            " XX  "
            "     "
          end
      },
      ?? => %{
        name: "question mark",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "   XX "
            "  XX  "
            "  XX  "
            "      "
            "  XX  "
          end
      },
      ?@ => %{
        name: "at sign",
        bitmap:
          defbitmap do
            "  XXXXXXXX  "
            " XX      XX "
            "XX  XX X  XX"
            "XX XX XX  XX"
            "XX  XX XXXX "
            " XX         "
            "  XXXXXXX   "
          end
      },
      ?A => %{
        name: "A",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?B => %{
        name: "B",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XXXXX "
          end
      },
      ?C => %{
        name: "C",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX    "
            "XX    "
            "XX    "
            "XX    "
            "XX    "
            " XXXXX"
          end
      },
      ?D => %{
        name: "D",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XXXXX "
          end
      },
      ?E => %{
        name: "E",
        bitmap:
          defbitmap do
            "XXXXXX"
            "XX    "
            "XX    "
            "XXXX  "
            "XX    "
            "XX    "
            "XXXXXX"
          end
      },
      ?F => %{
        name: "F",
        bitmap:
          defbitmap do
            "XXXXXX"
            "XX    "
            "XX    "
            "XXXX  "
            "XX    "
            "XX    "
            "XX    "
          end
      },
      ?G => %{
        name: "G",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX    "
            "XX XXX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?H => %{
        name: "H",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?I => %{
        name: "I",
        bitmap:
          defbitmap do
            "XXXX"
            " XX "
            " XX "
            " XX "
            " XX "
            " XX "
            "XXXX"
          end
      },
      ?J => %{
        name: "J",
        bitmap:
          defbitmap do
            "    XX"
            "    XX"
            "    XX"
            "    XX"
            "    XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?K => %{
        name: "K",
        bitmap:
          defbitmap do
            "XX   XX"
            "XX  XX "
            "XX XX  "
            "XXXX   "
            "XX XX  "
            "XX  XX "
            "XX   XX"
          end
      },
      ?L => %{
        name: "L",
        bitmap:
          defbitmap do
            "XX    "
            "XX    "
            "XX    "
            "XX    "
            "XX    "
            "XX    "
            "XXXXXX"
          end
      },
      ?M => %{
        name: "M",
        bitmap:
          defbitmap do
            "XX   XX"
            "XXX XXX"
            "XXXXXXX"
            "XX X XX"
            "XX   XX"
            "XX   XX"
            "XX   XX"
          end
      },
      ?N => %{
        name: "N",
        bitmap:
          defbitmap do
            "XX   XX"
            "XXX  XX"
            "XXXX XX"
            "XX XXXX"
            "XX  XXX"
            "XX   XX"
            "XX   XX"
          end
      },
      ?O => %{
        name: "O",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?P => %{
        name: "P",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XXXXX "
            "XX    "
            "XX    "
            "XX    "
          end
      },
      ?Q => %{
        name: "Q",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX XX "
            " XX XX"
          end
      },
      ?R => %{
        name: "R",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XXXXX "
            "XX XX "
            "XX  XX"
            "XX  XX"
          end
      },
      ?S => %{
        name: "S",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX    "
            " XXXX "
            "    XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?T => %{
        name: "T",
        bitmap:
          defbitmap do
            "XXXXXX"
            "  XX  "
            "  XX  "
            "  XX  "
            "  XX  "
            "  XX  "
            "  XX  "
          end
      },
      ?U => %{
        name: "U",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?V => %{
        name: "V",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
            "  XX  "
          end
      },
      ?W => %{
        name: "W",
        bitmap:
          defbitmap do
            "XX   XX"
            "XX   XX"
            "XX   XX"
            "XX   XX"
            "XX X XX"
            "XXX XXX"
            "XX   XX"
          end
      },
      ?X => %{
        name: "X",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            " XXXX "
            "  XX  "
            " XXXX "
            "XX  XX"
            "XX  XX"
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
            "XXXX"
            "XX  "
            "XX  "
            "XX  "
            "XX  "
            "XX  "
            "XXXX"
          end
      },
      ?\\ => %{
        name: "backslash",
        bitmap:
          defbitmap do
            "XX    "
            "XX    "
            " XX   "
            "  XX  "
            "   XX "
            "    XX"
            "    XX"
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
            "  XX  "
            " XXXX "
            "XX  XX"
            "      "
            "      "
            "      "
            "      "
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
            "XX "
            " XX"
            "   "
            "   "
            "   "
            "   "
            "   "
          end
      },
      ?a => %{
        name: "a",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXXX"
          end
      },
      ?b => %{
        name: "b",
        bitmap:
          defbitmap do
            "XX    "
            "XX    "
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XXXXX "
          end
      },
      ?c => %{
        name: "c",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX    "
            "XX    "
            "XX    "
            " XXXXX"
          end
      },
      ?d => %{
        name: "d",
        bitmap:
          defbitmap do
            "    XX"
            "    XX"
            " XXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXXX"
          end
      },
      ?e => %{
        name: "e",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX    "
            " XXXXX"
          end
      },
      ?f => %{
        name: "f",
        bitmap:
          defbitmap do
            "  XXX"
            " XX  "
            " XX  "
            "XXXXX"
            " XX  "
            " XX  "
            " XX  "
          end
      },
      ?g => %{
        name: "g",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX  XX"
            " XXXXX"
            "    XX"
            "XXXXX "
          end
      },
      ?h => %{
        name: "h",
        bitmap:
          defbitmap do
            "XX    "
            "XX    "
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?i => %{
        name: "i",
        bitmap:
          defbitmap do
            "XX"
            "  "
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
          end
      },
      ?j => %{
        name: "j",
        bitmap:
          defbitmap do
            "   XX"
            "     "
            "   XX"
            "   XX"
            "   XX"
            "XX XX"
            " XXX "
          end
      },
      ?k => %{
        name: "k",
        bitmap:
          defbitmap do
            "XX    "
            "XX XX "
            "XXXX  "
            "XXXX  "
            "XXXX  "
            "XX XX "
            "XX  XX"
          end
      },
      ?l => %{
        name: "l",
        bitmap:
          defbitmap do
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
          end
      },
      ?m => %{
        name: "m",
        bitmap:
          defbitmap do
            "XXX XXX "
            "XX XX XX"
            "XX XX XX"
            "XX XX XX"
            "XX XX XX"
          end
      },
      ?n => %{
        name: "n",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?o => %{
        name: "o",
        bitmap:
          defbitmap do
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?p => %{
        name: "p",
        bitmap:
          defbitmap do
            "XXXXX "
            "XX  XX"
            "XXXXX "
            "XX    "
            "XX    "
          end
      },
      ?q => %{
        name: "q",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX  XX"
            " XXXXX"
            "    XX"
            "    XX"
          end
      },
      ?r => %{
        name: "r",
        bitmap:
          defbitmap do
            " XXXX"
            "XX   "
            "XX   "
            "XX   "
            "XX   "
          end
      },
      ?s => %{
        name: "s",
        bitmap:
          defbitmap do
            " XXXXX"
            "XX    "
            " XXXX "
            "    XX"
            "XXXXX "
          end
      },
      ?t => %{
        name: "t",
        bitmap:
          defbitmap do
            " XX "
            " XX "
            "XXXX"
            " XX "
            " XX "
            " XX "
            " XX "
          end
      },
      ?u => %{
        name: "u",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?v => %{
        name: "v",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
            "  XX  "
          end
      },
      ?w => %{
        name: "w",
        bitmap:
          defbitmap do
            "XX    XX"
            "XX    XX"
            "XX XX XX"
            "XX XX XX"
            " XX  XX "
          end
      },
      ?x => %{
        name: "x",
        bitmap:
          defbitmap do
            "XX  XX"
            " XXXX "
            "  XX  "
            " XXXX "
            "XX  XX"
          end
      },
      ?y => %{
        name: "y",
        bitmap:
          defbitmap do
            "XX  XX"
            "XX  XX"
            " XXXXX"
            "    XX"
            "XXXXX "
          end
      },
      ?z => %{
        name: "z",
        bitmap:
          defbitmap do
            "XXXXXX"
            "   XX "
            "  XX  "
            " XX   "
            "XXXXXX"
          end
      },
      ?{ => %{
        name: "left curly bracket",
        bitmap:
          defbitmap do
            "  XX"
            " XX "
            " XX "
            "XX  "
            " XX "
            " XX "
            "  XX"
          end
      },
      ?| => %{
        name: "vertical bar",
        bitmap:
          defbitmap do
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
          end
      },
      ?} => %{
        name: "right curly bracket",
        bitmap:
          defbitmap do
            "XX  "
            " XX "
            " XX "
            "  XX"
            " XX "
            " XX "
            "XX  "
          end
      },
      ?~ => %{
        name: "tilde",
        bitmap:
          defbitmap do
            " XX    "
            "XX X XX"
            "    XX "
            "       "
            "       "
          end
      },

      # ISO 8859-1 CHARACTERS

      160 => %{
        name: "no-break space",
        bitmap:
          defbitmap do
            "  "
            "  "
            "  "
            "  "
            "  "
            "  "
            "  "
          end
      },
      ?¡ => %{
        name: "inverted exclamation mark",
        bitmap:
          defbitmap do
            "XX"
            "  "
            "XX"
            "XX"
            "XX"
            "XX"
            "XX"
          end
      },
      ?¢ => %{
        name: "cent sign",
        bitmap:
          defbitmap do
            "  XXXX"
            " XX   "
            "XXXXX "
            " XX   "
            "  XXXX"
            "      "
          end
      },
      ?£ => %{
        name: "pound sign",
        bitmap:
          defbitmap do
            "  XXXX"
            " XX   "
            " XX   "
            "XXXXX "
            " XX   "
            " XX   "
            "XXXXXX"
          end
      },
      ?¤ => %{
        name: "currency sign",
        bitmap:
          defbitmap do
            "      "
            "XX  XX"
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
            "XX  XX"
          end
      },
      ?¥ => %{
        name: "yen sign",
        bitmap:
          defbitmap do
            "XX  XX"
            " XXXX "
            "XXXXXX"
            "  XX  "
            "XXXXXX"
            "  XX  "
            "  XX  "
          end
      },
      ?¦ => %{
        name: "broken bar",
        bitmap:
          defbitmap do
            "XX"
            "XX"
            "XX"
            "  "
            "XX"
            "XX"
            "XX"
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
            " XXXXX "
            "XX   XX"
            "XX  XX "
            "XX XX  "
            "XX  XX "
            "XX   XX"
            "XX XXX "
            "XX     "
          end
      },
      ?Ä => %{
        name: "A with diaresis",
        bitmap:
          defbitmap do
            "      "
            "XX  XX"
            "      "
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?Á => %{
        name: "A with acute",
        bitmap:
          defbitmap do
            "   XX "
            "  XX  "
            "      "
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?À => %{
        name: "A with grave",
        bitmap:
          defbitmap do
            " XX   "
            "  XX  "
            "      "
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?Å => %{
        name: "A with ring",
        bitmap:
          defbitmap do
            " XXXX "
            " XXXX "
            "      "
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?Ã => %{
        name: "A with tilde",
        bitmap:
          defbitmap do
            " XX XX"
            "XX XX "
            "      "
            " XXXX "
            "XX  XX"
            "XXXXXX"
            "XX  XX"
            "XX  XX"
          end
      },
      ?ä => %{
        name: "a with diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            " XXXXX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXXX"
          end
      },
      ?Ö => %{
        name: "O with diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?ö => %{
        name: "o with diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            " XXXX "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?Ü => %{
        name: "U with diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?ü => %{
        name: "u with diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            "XX  XX"
            "XX  XX"
            "XX  XX"
            "XX  XX"
            " XXXX "
          end
      },
      ?¨ => %{
        name: "diaresis",
        bitmap:
          defbitmap do
            "XX  XX"
            "      "
            "      "
            "      "
            "      "
            "      "
            "      "
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
