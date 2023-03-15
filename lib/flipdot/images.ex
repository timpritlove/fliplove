defmodule Flipdot.Images do
  import Bitmap

  @space_invaders [
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "           X     X           X     X            XX             XX              XXXX               XXXX             ",
    "            X   X          X  X   X  X         XXXX           XXXX          XXXXXXXXXX         XXXXXXXXXX          ",
    "           XXXXXXX         X XXXXXXX X        XXXXXX         XXXXXX        XXXXXXXXXXXX       XXXXXXXXXXXX         ",
    "          XX XXX XX        XXX XXX XXX       XX XX XX       XX XX XX       XXX  XX  XXX       XXX  XX  XXX         ",
    "         XXXXXXXXXXX       XXXXXXXXXXX       XXXXXXXX       XXXXXXXX       XXXXXXXXXXXX       XXXXXXXXXXXX         ",
    "         X XXXXXXX X        XXXXXXXXX          X  X          X XX X           XX  XX            XXX  XXX           ",
    "         X X     X X         X     X          X XX X        X      X         XX XX XX          XX  XX  XX          ",
    "            XX XX           X       X        X X  X X        X    X        XX        XX         XX    XX           ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   "
  ]

  def space_invaders do
    defbitmap @space_invaders
  end

  @metaebene [
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                              XX                         XX                                        ",
    "                                              XX                         XX                                        ",
    "   XX XX XX XXXXXXXX   XXXXXXXXXXX   XXXXXXX  XXXXXX   XXXXXX   XXXXXXX  XXXXXXXX   XXXXXXX  XXXXXXXX   XXXXXXX    ",
    "   XX XX XX XXXXXXXX   XXXXXXXXXXXX XXXXXXXXX XXXXXX   XXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX   ",
    "   XX XX XX            XX   XX   XX XX     XX XX            XX XX     XX XX     XX XX     XX XX     XX XX     XX   ",
    "   XX XX XX XXXXXXXX   XX   XX   XX XXXXXXXXX XX      XXXXXXXX XXXXXXXXX XX     XX XXXXXXXXX XX     XX XXXXXXXXX   ",
    "   XX XX XX XXXXXXXX   XX   XX   XX XXXXXXXXX XX     XXXXXXXXX XXXXXXXXX XX     XX XXXXXXXXX XX     XX XXXXXXXXX   ",
    "   XX XX XX            XX   XX   XX XX        XX     XX     XX XX        XX     XX XX        XX     XX XX          ",
    "   XX XX XX XXXXXXXX   XX   XX   XX XXXXXXX   XXXXXX XXXXXXXXX XXXXXXXX  XXXXXXXXX XXXXXXXX  XX     XX XXXXXXX     ",
    "   XX XX XX XXXXXXXX   XX   XX   XX  XXXXXX    XXXXX  XXXXXXXX  XXXXXXX  XXXXXXXX   XXXXXXX  XX     XX  XXXXXX     ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   ",
    "                                                                                                                   "
  ]

  def metaebene do
    defbitmap @metaebene
  end
end
