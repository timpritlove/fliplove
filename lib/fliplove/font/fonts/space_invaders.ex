defmodule Fliplove.Font.Fonts.SpaceInvaders do
  alias Fliplove.Bitmap
  import Bitmap
  alias Fliplove.Font

  @font %Font{
    name: "space-invaders",
    properties: %{
      copyright: "Public domain font. Share and enjoy.",
      family_name: "Space Invaders",
      foundry: "AAA",
      weight_name: "Normal",
      slant: "R",
      pixel_size: 7
    },
    characters: %{
      0 => %{
        encoding: 0,
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
        encoding: ?\s,
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?! => %{
        encoding: ?!,
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "     "
            "  X  "
          end
      },
      ?" => %{
        encoding: ?",
        bitmap:
          defbitmap do
            " X X "
            " X X "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?# => %{
        encoding: ?#,
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
        encoding: ?$,
        bitmap:
          defbitmap baseline_y: -1 do
            "  X  "
            " XXX "
            "X X X"
            "X X  "
            " XXX "
            "  X X"
            "X X X"
            " XXX "
            "  X  "
          end
      },
      ?% => %{
        encoding: ?%,
        bitmap:
          defbitmap do
            "XX X "
            "XX X "
            "  X  "
            "  X  "
            "  X  "
            " X XX"
            " X XX"
          end
      },
      ?& => %{
        encoding: ?&,
        bitmap:
          defbitmap do
            " XX  "
            "X  X "
            "X  X "
            " XX  "
            "X  X "
            "X   X"
            " XXXX"
          end
      },
      ?' => %{
        encoding: ?',
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?( => %{
        encoding: ?(,
        bitmap:
          defbitmap do
            "   X "
            "  X  "
            " X   "
            " X   "
            " X   "
            "  X  "
            "   X "
          end
      },
      ?) => %{
        encoding: ?),
        bitmap:
          defbitmap do
            " X   "
            "  X  "
            "   X "
            "   X "
            "   X "
            "  X  "
            " X   "
          end
      },
      ?* => %{
        encoding: ?*,
        bitmap:
          defbitmap do
            "  X  "
            "X X X"
            " XXX "
            "  X  "
            " XXX "
            "X X X"
            "  X  "
          end
      },
      ?+ => %{
        encoding: ?1,
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
        encoding: ?,,
        bitmap:
          defbitmap baseline_y: -1 do
            "  X  "
            "  X  "
          end
      },
      ?- => %{
        encoding: ?-,
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            "XXXXX"
            "     "
            "     "
            "     "
          end
      },
      ?. => %{
        encoding: ?.,
        bitmap:
          defbitmap do
            "  X  "
          end
      },
      ?/ => %{
        encoding: ?/,
        bitmap:
          defbitmap do
            "   X "
            "   X "
            "  X  "
            "  X  "
            "  X  "
            " X   "
            " X   "
          end
      },
      ?0 => %{
        encoding: ?0,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X  XX"
            "X X X"
            "XX  X"
            "X   X"
            " XXX "
          end
      },
      ?1 => %{
        encoding: ?1,
        bitmap:
          defbitmap do
            "  X  "
            " XX  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            " XXX "
          end
      },
      ?2 => %{
        encoding: ?2,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "    X"
            "  XX "
            " X   "
            "X    "
            "XXXXX"
          end
      },
      ?3 => %{
        encoding: ?3,
        bitmap:
          defbitmap do
            "XXXXX"
            "    X"
            "   X "
            "  XX "
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?4 => %{
        encoding: ?4,
        bitmap:
          defbitmap do
            "   X "
            "  XX "
            " X X "
            "X  X "
            "XXXXX"
            "   X "
            "   X "
          end
      },
      ?5 => %{
        encoding: ?5,
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            " XXX "
            "    X"
            "X   X"
            " XXX "
          end
      },
      ?6 => %{
        encoding: ?6,
        bitmap:
          defbitmap do
            "  XXX"
            " X   "
            "X    "
            "XXXX "
            "X   X"
            "X   X"
            " XXX "
          end
      },
      ?7 => %{
        encoding: ?7,
        bitmap:
          defbitmap do
            "XXXXX"
            "    X"
            "   X "
            "  X  "
            " X   "
            " X   "
            " X   "
          end
      },
      ?8 => %{
        encoding: ?8,
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
        encoding: ?9,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            " XXXX"
            "    X"
            "   X "
            "XXX  "
          end
      },
      ?: => %{
        encoding: ?:,
        bitmap:
          defbitmap do
            "  X  "
            "     "
            "     "
            "     "
            "     "
            "  X  "
          end
      },
      ?; => %{
        encoding: ?;,
        bitmap:
          defbitmap baseline_y: -1 do
            "  X  "
            "     "
            "     "
            "     "
            "     "
            "  X  "
            "  X  "
          end
      },
      ?< => %{
        encoding: ?<,
        name: "less-than sign",
        bitmap:
          defbitmap do
            "   X "
            "  X  "
            " X   "
            "X    "
            " X   "
            "  X  "
            "   X "
          end
      },
      ?= => %{
        encoding: ?=,
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
        encoding: ?>,
        bitmap:
          defbitmap do
            " X   "
            "  X  "
            "   X "
            "    X"
            "   X "
            "  X  "
            " X   "
          end
      },
      ?? => %{
        encoding: ??,
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
        encoding: ?@,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X X X"
            "XX XX"
            "X X  "
            "X   X"
            " XXX "
          end
      },
      ?A => %{
        encoding: ?A,
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            "X   X"
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?B => %{
        encoding: ?B,
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
        encoding: ?C,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X    "
            "X    "
            "X    "
            "X   X"
            " XXX "
          end
      },
      ?D => %{
        encoding: ?D,
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
        encoding: ?E,
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXXX "
            "X    "
            "X    "
            "XXXXX"
          end
      },
      ?F => %{
        encoding: ?F,
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXXX "
            "X    "
            "X    "
            "X    "
          end
      },
      ?G => %{
        encoding: ?G,
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
        encoding: ?H,
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
        encoding: ?I,
        bitmap:
          defbitmap do
            " XXX "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            " XXX "
          end
      },
      ?J => %{
        encoding: ?J,
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
        encoding: ?K,
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
        encoding: ?L,
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
        encoding: ?M,
        bitmap:
          defbitmap do
            "X   X"
            "XX XX"
            "X X X"
            "X X X"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?N => %{
        encoding: ?N,
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
        encoding: ?O,
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
        encoding: ?P,
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
        encoding: ?Q,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X X X"
            "X  XX"
            " XXXX"
          end
      },
      ?R => %{
        encoding: ?R,
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
        encoding: ?S,
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
        encoding: ?T,
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
        encoding: ?U,
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
        encoding: ?V,
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
        encoding: ?W,
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "X X X"
            "X X X"
            "XX XX"
            "X   X"
          end
      },
      ?X => %{
        encoding: ?X,
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
        encoding: ?Y,
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            " X X "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?Z => %{
        encoding: ?Z,
        bitmap:
          defbitmap do
            "XXXXX"
            "    X"
            "   X "
            "  X  "
            " X   "
            "X    "
            "XXXXX"
          end
      },
      ?[ => %{
        encoding: ?[,
        bitmap:
          defbitmap do
            "  XX "
            " X   "
            " X   "
            " X   "
            " X   "
            " X   "
            "  XX "
          end
      },
      ?\\ => %{
        encoding: ?\\,
        bitmap:
          defbitmap do
            " X   "
            " X   "
            "  X  "
            "  X  "
            "  X  "
            "   X "
            "   X "
          end
      },
      ?] => %{
        encoding: ?],
        bitmap:
          defbitmap do
            " XX  "
            "   X "
            "   X "
            "   X "
            "   X "
            "   X "
            " XX  "
          end
      },
      ?^ => %{
        encoding: ?^,
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
        encoding: ?_,
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            "     "
            "     "
            "     "
            "XXXXX"
          end
      },
      ?` => %{
        encoding: ?`,
        bitmap:
          defbitmap do
            "  X  "
            "   X "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?a => %{
        encoding: ?a,
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            "X   X"
            "X   X"
            "XXXXX"
            "X   X"
            "X   X"
          end
      },
      ?b => %{
        encoding: ?b,
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
      ?c => %{
        encoding: ?c,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X    "
            "X    "
            "X    "
            "X   X"
            " XXX "
          end
      },
      ?d => %{
        encoding: ?d,
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
      ?e => %{
        encoding: ?e,
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXXX "
            "X    "
            "X    "
            "XXXXX"
          end
      },
      ?f => %{
        encoding: ?f,
        bitmap:
          defbitmap do
            "XXXXX"
            "X    "
            "X    "
            "XXXX "
            "X    "
            "X    "
            "X    "
          end
      },
      ?g => %{
        encoding: ?g,
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
      ?h => %{
        encoding: ?h,
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
      ?i => %{
        encoding: ?i,
        bitmap:
          defbitmap do
            " XXX "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            " XXX "
          end
      },
      ?j => %{
        encoding: ?j,
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
      ?k => %{
        encoding: ?k,
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
      ?l => %{
        encoding: ?l,
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
      ?m => %{
        encoding: ?m,
        bitmap:
          defbitmap do
            "X   X"
            "XX XX"
            "X X X"
            "X X X"
            "X   X"
            "X   X"
            "X   X"
          end
      },
      ?n => %{
        encoding: ?n,
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
      ?o => %{
        encoding: ?o,
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
      ?p => %{
        encoding: ?p,
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
      ?q => %{
        encoding: ?q,
        bitmap:
          defbitmap do
            " XXX "
            "X   X"
            "X   X"
            "X   X"
            "X X X"
            "X  XX"
            " XXXX"
          end
      },
      ?r => %{
        encoding: ?r,
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
      ?s => %{
        encoding: ?s,
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
      ?t => %{
        encoding: ?t,
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
      ?u => %{
        encoding: ?u,
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
      ?v => %{
        encoding: ?v,
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
      ?w => %{
        encoding: ?w,
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            "X   X"
            "X X X"
            "X X X"
            "XX XX"
            "X   X"
          end
      },
      ?x => %{
        encoding: ?x,
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
      ?y => %{
        encoding: ?y,
        bitmap:
          defbitmap do
            "X   X"
            "X   X"
            " X X "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?z => %{
        encoding: ?z,
        bitmap:
          defbitmap do
            "XXXXX"
            "    X"
            "   X "
            "  X  "
            " X   "
            "X    "
            "XXXXX"
          end
      },
      ?{ => %{
        encoding: ?{,
        bitmap:
          defbitmap do
            "   X "
            "  X  "
            "  X  "
            " X   "
            "  X  "
            "  X  "
            "   X "
          end
      },
      ?| => %{
        encoding: ?|,
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?} => %{
        encoding: ?},
        bitmap:
          defbitmap do
            " X   "
            "  X  "
            "  X  "
            "   X "
            "  X  "
            "  X  "
            " X   "
          end
      },
      ?~ => %{
        encoding: ?~,
        bitmap:
          defbitmap do
            "     "
            "     "
            "  X X"
            " X X "
            "     "
            "     "
            "     "
          end
      },

      # ISO 8859-1 CHARACTERS

      160 => %{
        encoding: 160,
        name: "no-break space",
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
      ?¡ => %{
        encoding: ?¡,
        name: "inverted exclamation mark",
        bitmap:
          defbitmap do
            "  X  "
            "     "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?¢ => %{
        encoding: ?¢,
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
        encoding: ?£,
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
        encoding: ?¤,
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
        encoding: ?¥,
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
        encoding: ?¦,
        name: "broken bar",
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "  X  "
            "     "
            "  X  "
            "  X  "
            "  X  "
          end
      },
      ?§ => %{
        encoding: ?§,
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
      ?¨ => %{
        encoding: ?¨,
        name: "diaresis",
        bitmap:
          defbitmap do
            " X X "
            "     "
            "     "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?© => %{
        encoding: ?©,
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
        encoding: ?€,
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
        encoding: ?¯,
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
        encoding: ?°,
        name: "degree sign",
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            "  X  "
            "     "
            "     "
            "     "
            "     "
          end
      },
      ?± => %{
        encoding: ?±,
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
        encoding: ?²,
        name: "superscript two",
        bitmap:
          defbitmap do
            " XX  "
            "   X "
            "  X  "
            " X   "
            " XXX "
            "     "
            "     "
          end
      },
      ?³ => %{
        encoding: ?³,
        name: "superscript three",
        bitmap:
          defbitmap do
            " XX  "
            "   X "
            "  X  "
            "   X "
            " XX  "
            "     "
            "     "
          end
      },
      ?´ => %{
        encoding: ?´,
        name: "acute accent",
        bitmap:
          defbitmap baseline_y: 5 do
            "   X "
            "  X  "
          end
      },
      ?µ => %{
        encoding: ?µ,
        name: "micro sign",
        bitmap:
          defbitmap baseline_y: -1 do
            "     "
            "     "
            "     "
            "    X"
            " X  X"
            " X  X"
            " XXX "
            " X   "
            " X   "
          end
      },
      ?· => %{
        encoding: ?·,
        name: "middle dot",
        bitmap:
          defbitmap do
            "     "
            "     "
            "     "
            "  X  "
            "     "
            "     "
            "     "
          end
      },
      ?¹ => %{
        encoding: ?¹,
        name: "superscript one",
        bitmap:
          defbitmap do
            "  X  "
            " XX  "
            "  X  "
            "  X  "
            " XXX "
            "     "
            "     "
          end
      },
      ?ª => %{
        encoding: ?ª,
        name: "feminine ordinal indicator",
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            " XXX "
            " X X "
            "     "
            "     "
            "     "
          end
      },
      ?º => %{
        encoding: ?º,
        name: "masculine ordinal indicator",
        bitmap:
          defbitmap do
            "  X  "
            " X X "
            " X X "
            "  X  "
            "     "
            "     "
            "     "
          end
      },
      ?« => %{
        encoding: ?«,
        name: "left-pointing double angle quotation mark",
        bitmap:
          defbitmap do
            "     "
            "  X X"
            " X X "
            "X X  "
            " X X "
            "  X X"
            "     "
          end
      },
      ?¬ => %{
        encoding: ?¬,
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
        encoding: ?»,
        name: "right-pointing double angle quotation mark",
        bitmap:
          defbitmap do
            "     "
            "X X  "
            " X X "
            "  X X"
            " X X "
            "X X  "
            "     "
          end
      },
      ?¼ => %{
        encoding: ?¼,
        name: "vulgar fraction one quarter",
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "  X  "
            "     "
            " X X "
            " XXX "
            "   X "
          end
      },
      ?½ => %{
        encoding: ?½,
        name: "vulgar fraction one half",
        bitmap:
          defbitmap do
            "  X  "
            "  X  "
            "  X  "
            "     "
            " XX  "
            "  X  "
            "  XX "
          end
      },
      ?¾ => %{
        encoding: ?¾,
        name: "vulgar fraction three quarters",
        bitmap:
          defbitmap do
            " XX  "
            "  XX "
            " XX  "
            "     "
            " X X "
            " XXX "
            "   X "
          end
      },
      ?¿ => %{
        encoding: ?¿,
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
      },

      # SPACE INVADERS

      ?á => %{
        encoding: ?á,
        name: "crab_invader_0",
        bitmap:
          defbitmap do
            "  X     X  "
            "   X   X   "
            "  XXXXXXX  "
            " XX XXX XX "
            "XXXXXXXXXXX"
            "X XXXXXXX X"
            "X X     X X"
            "   XX XX   "
          end
      },
      ?à => %{
        encoding: ?à,
        name: "crab_invader_1",
        bitmap:
          defbitmap do
            "  X     X  "
            "X  X   X  X"
            "X XXXXXXX X"
            "XXX XXX XXX"
            "XXXXXXXXXXX"
            " XXXXXXXXX "
            "  X     X  "
            " X       X "
          end
      },
      ?í => %{
        encoding: ?ì,
        name: "squid_invader_0",
        bitmap:
          defbitmap do
            "   XX   "
            "  XXXX  "
            " XXXXXX "
            "XX XX XX"
            "XXXXXXXX"
            "  X  X  "
            " X XX X "
            "X X  X X"
          end
      },
      ?ì => %{
        encoding: ?ì,
        name: "squid_invader_1",
        bitmap:
          defbitmap do
            "   XX   "
            "  XXXX  "
            " XXXXXX "
            "XX XX XX"
            "XXXXXXXX"
            " X XX X "
            "X      X"
            " X    X "
          end
      },
      ?ó => %{
        encoding: ?ó,
        name: "octopus_invader_0",
        bitmap:
          defbitmap do
            "    XXXX    "
            " XXXXXXXXXX "
            "XXXXXXXXXXXX"
            "XXX  XX  XXX"
            "XXXXXXXXXXXX"
            "   XX  XX   "
            "  XX XX XX  "
            "XX        XX"
          end
      },
      ?ò => %{
        encoding: ?ò,
        name: "octopus_invader_1",
        bitmap:
          defbitmap do
            "    XXXX    "
            " XXXXXXXXXX "
            "XXXXXXXXXXXX"
            "XXX  XX  XXX"
            "XXXXXXXXXXXX"
            "  XXX  XXX  "
            " XX  XX  XX "
            "  XX    XX  "
          end
      },
      ?å => %{
        encoding: ?å,
        name: "invader_ufo",
        bitmap:
          defbitmap do
            "     XXXXXX     "
            "   XXXXXXXXXX   "
            "  XXXXXXXXXXXX  "
            " XX XX XX XX XX "
            "XXXXXXXXXXXXXXXX"
            "  XXX  XX   XXX "
            "   X         X  "
          end
      }
    }
  }

  def get, do: @font
end
