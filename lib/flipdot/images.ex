defmodule Flipdot.Images do
  import Bitmap

  @space_invaders defbitmap [
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

  @metaebene defbitmap [
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

  @fluepdot defbitmap([
              "                                                                                                                   ",
              "                              XXX  XX                                   XX          XX                             ",
              "                             XXXX  XX                                   XX          XX                             ",
              "                             XX   XX                                   XX           XX                             ",
              "                           XXXXX XX  XX    XX   XXXX   XX XXX     XXX XX    XXXX  XXXXX                            ",
              "                           XXXXX XX  XX    XX  XXXXXX  XXXXXXX   XXXXXXX  XXXXXXX XXXXX                            ",
              "                            XX   XX  XX    XX XX   XX  XX   XX  XX   XXX XXX   XX  XX                              ",
              "                           XX   XX  XX    XX XXXXXXXX XXX   XX  XX   XX  XX    XX  XX                              ",
              "                           XX   XX  XX    XX XXXXXXXX XX    XX XX    XX XX     XX XX                               ",
              "                           XX   XX  XX    XX XX       XX   XX  XX   XXX XX    XX  XX                               ",
              "                          XX   XX  XX   XXX  XXX  XX XXX   XX  XX   XX  XX   XXX XX                                ",
              "                          XX   XX  XXXXXXXX  XXXXXXX XXXXXXX   XXXXXXX  XXXXXXX  XXXX                              ",
              "                          XX   XX   XXXX XX   XXXXX  XX XXX     XXX XX   XXXX     XXX                              ",
              "                                                     XX                                                            ",
              "                                                    XX                                                             ",
              "                                                    XX                                                             "
            ])

  @images %{
    "space-invaders" => @space_invaders,
    "metaebene" => @metaebene,
    "fluepdot" => @fluepdot
  }

  def images do
    @images
  end
end
