defmodule BitmapTest do
  use ExUnit.Case
  doctest Fliplove.Bitmap
  alias Fliplove.Bitmap

  def invader do
    Bitmap.from_lines_of_text([
      "  X     X  ",
      "   X   X   ",
      "  XXXXXXX  ",
      " XX XXX XX ",
      "XXXXXXXXXXX",
      "X XXXXXXX X",
      "X X     X X",
      "   XX XX   "
    ])
  end

  def inverted_invader do
    invader() |> Bitmap.invert()
  end

  test "create simple bitmap" do
    assert Bitmap.new(2, 2) |> inspect == """

           ++-+
           |  |
           +  +
           ++-+
           """
  end

  test "set pixel value" do
    bitmap = Bitmap.new(2, 2) |> Bitmap.set_pixel({0, 0}, 1)
    assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
    assert Bitmap.get_pixel(bitmap, {1, 1}) == 0
  end

  test "toggle pixel value" do
    bitmap = Bitmap.new(2, 2) |> Bitmap.toggle_pixel({0, 0})
    assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
    bitmap = bitmap |> Bitmap.toggle_pixel({0, 0})
    assert Bitmap.get_pixel(bitmap, {0, 0}) == 0
  end

  test "create bitmap from lines of text" do
    assert invader() |> inspect() == """

           ++----------+
           |  X     X  |
           |   X   X   |
           |  XXXXXXX  |
           | XX XXX XX |
           |XXXXXXXXXXX|
           |X XXXXXXX X|
           |X X     X X|
           +   XX XX   +
           ++----------+
           """
  end

  test "bitmap to text" do
    assert invader() |> Bitmap.to_text() ==
             "  X     X  \n   X   X   \n  XXXXXXX  \n XX XXX XX \nXXXXXXXXXXX\nX XXXXXXX X\nX X     X X\n   XX XX   \n"
  end

  test "bitmap to binary" do
    assert invader() |> Bitmap.to_binary() == <<112, 24, 125, 182, 188, 60, 188, 182, 125, 24, 112>>
  end

  test "bitmap dimensions" do
    assert Bitmap.dimensions(invader()) == {11, 8}
  end

  test "invert bitmap" do
    assert invader() |> Bitmap.invert() |> inspect() == """

           ++----------+
           |XX XXXXX XX|
           |XXX XXX XXX|
           |XX       XX|
           |X  X   X  X|
           |           |
           | X       X |
           | X XXXXX X |
           +XXX  X  XXX+
           ++----------+
           """
  end

  test "scale bitmap" do
    assert invader() |> Bitmap.scale(2) |> inspect() == """

           ++---------------------+
           |    XX          XX    |
           |    XX          XX    |
           |      XX      XX      |
           |      XX      XX      |
           |    XXXXXXXXXXXXXX    |
           |    XXXXXXXXXXXXXX    |
           |  XXXX  XXXXXX  XXXX  |
           |  XXXX  XXXXXX  XXXX  |
           |XXXXXXXXXXXXXXXXXXXXXX|
           |XXXXXXXXXXXXXXXXXXXXXX|
           |XX  XXXXXXXXXXXXXX  XX|
           |XX  XXXXXXXXXXXXXX  XX|
           |XX  XX          XX  XX|
           |XX  XX          XX  XX|
           |      XXXX  XXXX      |
           +      XXXX  XXXX      +
           ++---------------------+
           """
  end

  test "rotate bitmap" do
    assert invader() |> Bitmap.rotate() |> inspect() == """

           ++-------+
           | XXX    |
           |   XX   |
           | XXXXX X|
           |X XX XX |
           |X XXXX  |
           |  XXXX  |
           |X XXXX  |
           |X XX XX |
           | XXXXX X|
           |   XX   |
           + XXX    +
           ++-------+
           """
  end

  test "translate bitmap" do
    assert invader() |> Bitmap.translate({3, 5}) |> inspect() == """

           ++----------+
           |   X XXXXXX|
           |   X X     |
           |      XX XX|
           |           |
           |           |
           |           |
           |           |
           +           +
           ++----------+
           """
  end

  test "fill bitmap" do
    assert invader() |> Bitmap.fill({5, 1}) |> inspect() == """

           ++----------+
           |  X     X  |
           |   X   X   |
           |  XXXXXXX  |
           | XX XXX XX |
           |XXXXXXXXXXX|
           |X XXXXXXX X|
           |X XXXXXXX X|
           +   XXXXX   +
           ++----------+
           """
  end

  test "game of life" do
    assert invader() |> Bitmap.GameOfLife.game_of_life() |> inspect() == """

           ++----------+
           |           |
           |     X     |
           | X       X |
           |X         X|
           |X         X|
           |X         X|
           |  X     X  |
           +   X   X   +
           ++----------+
           """
  end

  test "clip bitmap" do
    assert invader() |> Bitmap.translate({0, -4}) |> Bitmap.clip() |> inspect() == """

           ++--------+
           | X     X |
           |  X   X  |
           | XXXXXXX |
           +XX XXX XX+
           ++--------+
           """
  end

  test "set pixel on bitmap" do
    assert invader() |> Bitmap.set_pixel({3, 4}, 1) |> Bitmap.set_pixel({7, 4}, 1) |> inspect() == """

           ++----------+
           |  X     X  |
           |   X   X   |
           |  XXXXXXX  |
           | XXXXXXXXX |
           |XXXXXXXXXXX|
           |X XXXXXXX X|
           |X X     X X|
           +   XX XX   +
           ++----------+
           """
  end

  test "crop bitmap" do
    assert invader() |> Bitmap.crop({2, 2}, 7, 4) |> inspect() == """

           ++------+
           |XXXXXXX|
           |X XXX X|
           |XXXXXXX|
           +XXXXXXX+
           ++------+
           """
  end
end
