si = Fliplove.Bitmap.from_file("data/frames/fb_space_invaders.txt")

invader =
  Fliplove.Bitmap.from_lines_of_text([
    "  X     X  ",
    "   X   X   ",
    "  XXXXXXX  ",
    " XX XXX XX ",
    "XXXXXXXXXXX",
    "X XXXXXXX X",
    "X X     X X",
    "   XX XX   "
  ])

f = Fliplove.Font.Fonts.Flipdot.get()
