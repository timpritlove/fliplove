defmodule BitmapTransitionTest do
  use ExUnit.Case
  doctest Fliplove.Bitmap
  alias Fliplove.Bitmap

  def invader() do
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

  def inverted_invader() do
    invader() |> Bitmap.invert()
  end

  test "push_up transition" do
    assert Bitmap.Transition.push_up(invader(), inverted_invader()) |> Enum.at(4) |> inspect() == """

           ++----------+
           |XXXXXXXXXXX|
           |X XXXXXXX X|
           |X X     X X|
           |   XX XX   |
           |XX XXXXX XX|
           |XXX XXX XXX|
           |XX       XX|
           +X  X   X  X+
           ++----------+
           """
  end
end
