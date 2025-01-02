defmodule Fliplove.Images do
  alias Fliplove.Bitmap

  @moduledoc false

  import Bitmap

  @crab_invader defbitmap [
                  "  X     X  ",
                  "   X   X   ",
                  "  XXXXXXX  ",
                  " XX XXX XX ",
                  "XXXXXXXXXXX",
                  "X XXXXXXX X",
                  "X X     X X",
                  "   XX XX   "
                ]

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
               "                                               XX                         XX                                       ",
               "                                               XX                         XX                                       ",
               "  XX XX XX XXXXXXXX     XXXXXXXXXXX   XXXXXXX  XXXXXX   XXXXXX   XXXXXXX  XXXXXXXX   XXXXXXX  XXXXXXXX   XXXXXXX   ",
               "  XX XX XX XXXXXXXX     XXXXXXXXXXXX XXXXXXXXX XXXXXX   XXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX XXXXXXXXX  ",
               "  XX XX XX              XX   XX   XX XX     XX XX            XX XX     XX XX     XX XX     XX XX     XX XX     XX  ",
               "  XX XX XX XXXXXXXX     XX   XX   XX XXXXXXXXX XX      XXXXXXXX XXXXXXXXX XX     XX XXXXXXXXX XX     XX XXXXXXXXX  ",
               "  XX XX XX XXXXXXXX     XX   XX   XX XXXXXXXXX XX     XXXXXXXXX XXXXXXXXX XX     XX XXXXXXXXX XX     XX XXXXXXXXX  ",
               "  XX XX XX              XX   XX   XX XX        XX     XX     XX XX        XX     XX XX        XX     XX XX         ",
               "  XX XX XX XXXXXXXX     XX   XX   XX XXXXXXX   XXXXXX XXXXXXXXX XXXXXXXX  XXXXXXXXX XXXXXXXX  XX     XX XXXXXXX    ",
               "  XX XX XX XXXXXXXX     XX   XX   XX  XXXXXX    XXXXX  XXXXXXXX  XXXXXXX  XXXXXXXX   XXXXXXX  XX     XX  XXXXXX    ",
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

  @pacman defbitmap [
            "                                                                                                                   ",
            "                                                      XXXX                        XXXX              XXXX           ",
            "             XXXXX                                  XXXXXXXX                    XXXXXXXX          XXXXXXXX         ",
            "           XXXXXXXXX                               XXXXXXXXXX                  XXXXXXXXXX        XXXXXXXXXX        ",
            "          XXXXXXXXXXX                             XXXXXXXXXXXX                XXX  XXXX  X      XXX  XXXX  X       ",
            "          XXXXXXXXXXX                             XXXXXXXXXXXX                XX    XX          XX    XX           ",
            "         XXXXXXXXXX                               XXX  XX  XXX                XX  XXXX  XX      XX  XXXX  XX       ",
            "         XXXXXXX                                 XXXX  XX  XXXX              XXX  XXXX  XXX    XXX  XXXX  XXX      ",
            "         XXXX            XX      XX      XX      XXXXXXXXXXXXXX              XXXX  XXXX  XX    XXXX  XXXX  XX      ",
            "         XXXXXXX         XX      XX      XX      XXXXXXXXXXXXXX              XXXXXXXXXXXXXX    XXXXXXXXXXXXXX      ",
            "         XXXXXXXXXX                              XX  XX  XX  XX              XXXXXXXXXXXXXX    XXXXXXXXXXXXXX      ",
            "          XXXXXXXXXXX                            X XX  XX  XX X              XXXXXXXXXXXXXX    XXXXXXXXXXXXXX      ",
            "          XXXXXXXXXXX                            XXXXXXXXXXXXXX              XXXXXXXXXXXXXX    XXXXXXXXXXXXXX      ",
            "           XXXXXXXXX                             XXXX XXXX XXXX              XXXX XXXX XXXX    XXXX XXXX XXXX      ",
            "             XXXXX                                XX   XX   XX                XX   XX   XX      XX   XX   XX       ",
            "                                                                                                                   "
          ]

  @blinkenlights defbitmap [
                   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                   "X                                                                                                                 X",
                   "X                                                                                                                 X",
                   "X                                                                                                                 X",
                   "X                                  X   X X     X           X X  XX X   X                                          X",
                   "X                                  X   X       X           X    X  X   X                                          X",
                   "X                                  XXX X X XX  XXX XXX XX  X X XXX XXX XX XXX                                     X",
                   "X                                  X X X X XXX XX  X X XXX X X X X X X X  X                                       X",
                   "X                                  X X X X X X XXX XXX X X X X XXX X X X  XXX                                     X",
                   "X                                  X X X X X X X X X   X X X X  X  X X X    X                                     X",
                   "X                                  XXX X X X X X X XX  X X X X XXX X X XX XXX                                     X",
                   "X                                                              X X                                                X",
                   "X                                                              XXX                                                X",
                   "X                                                                                                                 X",
                   "X                                                                                                                 X",
                   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                 ]

  @images %{
    "space-invaders" => @space_invaders,
    "pacman" => @pacman,
    "metaebene" => @metaebene,
    "fluepdot" => @fluepdot,
    "blinkenlights" => @blinkenlights,
    "crab-invader" => @crab_invader
  }

  def images do
    @images
  end

  @doc """
  Reads all *.txt files from priv/static/slideshow directory and converts them to Bitmaps.
  Optionally accepts :width and :height parameters to filter images by dimensions.

  Returns a list of Bitmaps that match the specified dimensions (if any).
  Silently skips files that can't be parsed or don't match the dimensions.
  """
  def load_slideshow_images(opts \\ []) do
    width = Keyword.get(opts, :width)
    height = Keyword.get(opts, :height)

    Path.wildcard("priv/static/slideshow/*.txt")
    |> Enum.reduce([], fn file_path, acc ->
      try do
        bitmap = Bitmap.from_file(file_path)

        cond do
          width && bitmap.width != width -> acc
          height && bitmap.height != height -> acc
          true -> [bitmap | acc]
        end
      rescue
        e ->
          require Logger
          Logger.error("Failed to load slideshow image #{file_path}: #{Exception.message(e)}")
          acc
      end
    end)
    |> Enum.reverse()
  end
end
