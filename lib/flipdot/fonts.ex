defmodule Flipdot.Fonts do
  import Bitmap

  def font_space_invaders do
    %{
      version: "2.1",
      name: "space-invaders",
      properties: %{
        copyright: "Public domain font. Share and enjoy."
      },
      characters: %{
        ?\s => %{
          encoding: ?\s,
          bitmap:
            defbitmap([
              "     ",
              "     ",
              "     ",
              "     ",
              "     ",
              "     ",
              "     "
            ])
        },
        ?! => %{
          encoding: ?!,
          bitmap:
            defbitmap([
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "     ",
              "  X  "
            ])
        },
        ?" => %{
          encoding: ?",
          bitmap:
            defbitmap([
              " X X ",
              " X X ",
              "     ",
              "     ",
              "     ",
              "     ",
              "     "
            ])
        },
        ?# => %{
          encoding: ?#,
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
          encoding: ?$,
          bb_y_off: -1,
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
            ])
        },
        ?% => %{
          encoding: ?%,
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
          encoding: ?&,
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
        ?´ => %{
          encoding: ?´,
          bb_y_off: 5,
          bitmap:
            defbitmap([
              "   X ",
              "  X  "
            ])
        },
        ?( => %{
          encoding: ?(,
          bitmap:
            defbitmap([
              "   X ",
              "  X  ",
              " X   ",
              " X   ",
              " X   ",
              "  X  ",
              "   X "
            ])
        },
        ?) => %{
          encoding: ?),
          bitmap:
            defbitmap([
              " X   ",
              "  X  ",
              "   X ",
              "   X ",
              "   X ",
              "  X  ",
              " X   "
            ])
        },
        ?* => %{
          encoding: ?*,
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
          encoding: ?1,
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
          encoding: ?,,
          bb_y_off: -1,
          bitmap:
            defbitmap([
              "  X  ",
              "  X  "
            ])
        },
        ?- => %{
          encoding: ?-,
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
          encoding: ?.,
          bitmap:
            defbitmap([
              "  X  "
            ])
        },
        ?/ => %{
          encoding: ?/,
          bitmap:
            defbitmap([
              "   X ",
              "   X ",
              "  X  ",
              "  X  ",
              "  X  ",
              " X   ",
              " X   "
            ])
        },
        ?0 => %{
          encoding: ?0,
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
          encoding: ?1,
          bitmap:
            defbitmap([
              "  X  ",
              " XX  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              " XXX "
            ])
        },
        ?2 => %{
          encoding: ?2,
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
          encoding: ?3,
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
          encoding: ?4,
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
          encoding: ?5,
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
          encoding: ?6,
          bitmap:
            defbitmap([
              "  XXX",
              " X   ",
              "X    ",
              "XXXX ",
              "X   X",
              "X   X",
              " XXX "
            ])
        },
        ?7 => %{
          encoding: ?7,
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
          encoding: ?8,
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
          encoding: ?9,
          bitmap:
            defbitmap([
              " XXX ",
              "X   X",
              "X   X",
              " XXXX",
              "    X",
              "   X ",
              "XXX  "
            ])
        },
        ?: => %{
          encoding: ?:,
          bitmap:
            defbitmap([
              "     ",
              "  X  ",
              "     ",
              "     ",
              "     ",
              "     ",
              "  X  "
            ])
        },
        ?; => %{
          encoding: ?;,
          bb_y_off: -1,
          bitmap:
            defbitmap([
              "  X  ",
              "     ",
              "     ",
              "     ",
              "     ",
              "  X  ",
              "  X  "
            ])
        },
        ?< => %{
          encoding: ?<,
          bitmap:
            defbitmap([
              "   X ",
              "  X  ",
              " X   ",
              "X    ",
              " X   ",
              "  X  ",
              "   X "
            ])
        },
        ?= => %{
          encoding: ?=,
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
          encoding: ?>,
          bitmap:
            defbitmap([
              " X   ",
              "  X  ",
              "   X ",
              "    X",
              "   X ",
              "  X  ",
              " X   "
            ])
        },
        ?? => %{
          encoding: ??,
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
          encoding: ?@,
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
          encoding: ?A,
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
          encoding: ?B,
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
          encoding: ?C,
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
          encoding: ?D,
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
          encoding: ?E,
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
          encoding: ?F,
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
          encoding: ?G,
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
          encoding: ?H,
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
          encoding: ?I,
          bitmap:
            defbitmap([
              " XXX ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              " XXX "
            ])
        },
        ?J => %{
          encoding: ?J,
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
          encoding: ?K,
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
          encoding: ?L,
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
          encoding: ?M,
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
          encoding: ?N,
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
          encoding: ?O,
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
          encoding: ?P,
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
          encoding: ?Q,
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
          encoding: ?R,
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
          encoding: ?S,
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
          encoding: ?T,
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
          encoding: ?U,
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
          encoding: ?V,
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
          encoding: ?W,
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
          encoding: ?X,
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
          encoding: ?Y,
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
          encoding: ?Z,
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
          encoding: ?[,
          bitmap:
            defbitmap([
              "  XX ",
              " X   ",
              " X   ",
              " X   ",
              " X   ",
              " X   ",
              "  XX "
            ])
        },
        ?\\ => %{
          encoding: ?\\,
          bitmap:
            defbitmap([
              " X   ",
              " X   ",
              "  X  ",
              "  X  ",
              "  X  ",
              "   X ",
              "   X "
            ])
        },
        ?] => %{
          encoding: ?],
          bitmap:
            defbitmap([
              " XX  ",
              "   X ",
              "   X ",
              "   X ",
              "   X ",
              "   X ",
              " XX  "
            ])
        },
        ?^ => %{
          encoding: ?^,
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
          encoding: ?_,
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
          encoding: ?`,
          bitmap:
            defbitmap([
              "  X  ",
              "   X ",
              "     ",
              "     ",
              "     ",
              "     ",
              "     "
            ])
        },
        ?a => %{
          encoding: ?a,
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
        ?b => %{
          encoding: ?b,
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
        ?c => %{
          encoding: ?c,
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
        ?d => %{
          encoding: ?d,
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
        ?e => %{
          encoding: ?e,
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
        ?f => %{
          encoding: ?f,
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
        ?g => %{
          encoding: ?g,
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
        ?h => %{
          encoding: ?h,
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
        ?i => %{
          encoding: ?i,
          bitmap:
            defbitmap([
              " XXX ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              " XXX "
            ])
        },
        ?j => %{
          encoding: ?j,
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
        ?k => %{
          encoding: ?k,
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
        ?l => %{
          encoding: ?l,
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
        ?m => %{
          encoding: ?m,
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
        ?n => %{
          encoding: ?n,
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
        ?o => %{
          encoding: ?o,
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
        ?p => %{
          encoding: ?p,
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
        ?q => %{
          encoding: ?q,
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
        ?r => %{
          encoding: ?r,
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
        ?s => %{
          encoding: ?s,
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
        ?t => %{
          encoding: ?t,
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
        ?u => %{
          encoding: ?u,
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
        ?v => %{
          encoding: ?v,
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
        ?w => %{
          encoding: ?w,
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
        ?x => %{
          encoding: ?x,
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
        ?y => %{
          encoding: ?y,
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
        ?z => %{
          encoding: ?z,
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
        ?{ => %{
          encoding: ?{,
          bitmap:
            defbitmap([
              "   X ",
              "  X  ",
              "  X  ",
              " X   ",
              "  X  ",
              "  X  ",
              "   X "
            ])
        },
        ?| => %{
          encoding: ?|,
          bitmap:
            defbitmap([
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  ",
              "  X  "
            ])
        },
        ?} => %{
          encoding: ?},
          bitmap:
            defbitmap([
              " X   ",
              "  X  ",
              "  X  ",
              "   X ",
              "  X  ",
              "  X  ",
              " X   "
            ])
        },
        ?~ => %{
          encoding: ?~,
          bitmap:
            defbitmap([
              "     ",
              "     ",
              "  X X",
              " X X ",
              "     ",
              "     ",
              "     "
            ])
        },
        ?§ => %{
          encoding: ?§,
          bitmap:
            defbitmap([
              " XXX ",
              "X   X",
              " XX  ",
              " X X ",
              "  XX ",
              "X   X",
              " XXX "
            ])
        },
        ?€ => %{
          encoding: ?€,
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
        ?° => %{
          encoding: ?°,
          bitmap:
            defbitmap([
              "  X  ",
              " X X ",
              "  X  ",
              "     ",
              "     ",
              "     ",
              "     "
            ])
        },

        # SPACE INVADERS

        ?á => %{
          encoding: ?á,
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
          encoding: ?à,
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
          encoding: ?ì,
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
          encoding: ?ì,
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
          encoding: ?ó,
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
          encoding: ?ò,
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
        ?Æ => %{
          encoding: ?Æ,
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
        }
      }
    }
  end
end
