defmodule Fliplove.Bitmap.Transition do
  @moduledoc """
  Bitmap transition effects for creating smooth animations.

  This module provides various transition effects between two bitmaps, generating
  a stream of intermediate frames for smooth animation on flipdot displays.

  ## Available Transitions
  - `push_up/2` - Pushes the first bitmap up while the second bitmap slides in from below
  - `push_down/2` - Pushes the first bitmap down while the second bitmap slides in from above

  ## Usage
      bitmap_a = Fliplove.Bitmap.new(20, 16)
      bitmap_b = Fliplove.Bitmap.new(20, 16)

      # Create transition stream
      frames = Fliplove.Bitmap.Transition.push_up(bitmap_a, bitmap_b)

      # Display each frame
      Enum.each(frames, &Fliplove.Driver.set_bitmap/1)

  Both bitmaps must have identical dimensions for transitions to work.
  """
  alias Fliplove.Bitmap
  # TODO: Add more transition effects for complete animation library
  # * slide transitions in all directions (slide_left, slide_right, slide_up, slide_down)
  # * push transitions in all directions (push_left, push_right - currently only have up/down)
  # * Consider adding fade, wipe, and other transition types

  def push_up(bitmap_a, bitmap_b) do
    {width, height} = Bitmap.dimensions(bitmap_a)

    if {width, height} != Bitmap.dimensions(bitmap_b) do
      raise("Bitmaps must have identical dimensions")
    end

    Stream.resource(
      fn ->
        bitmap_ab =
          Bitmap.new(width, height * 2)
          |> Bitmap.overlay(bitmap_a, cursor_x: 0, cursor_y: height)
          |> Bitmap.overlay(bitmap_b, cursor_x: 0, cursor_y: 0)

        {bitmap_ab, height}
      end,
      fn {bitmap_ab, row} ->
        if row < 0 do
          {:halt, nil}
        else
          bitmap = Bitmap.crop(bitmap_ab, {0, row}, width, height)
          {[bitmap], {bitmap_ab, row - 1}}
        end
      end,
      fn _ -> nil end
    )
  end

  def push_down(bitmap_a, bitmap_b) do
    {width, height} = Bitmap.dimensions(bitmap_a)

    if {width, height} != Bitmap.dimensions(bitmap_b) do
      raise("Bitmaps must have identical dimensions")
    end

    Stream.resource(
      fn ->
        bitmap_ab =
          Bitmap.new(width, height * 2)
          |> Bitmap.overlay(bitmap_a, cursor_x: 0, cursor_y: 0)
          |> Bitmap.overlay(bitmap_b, cursor_x: 0, cursor_y: height)

        {bitmap_ab, 0}
      end,
      fn {bitmap_ab, row} ->
        if row > height do
          {:halt, nil}
        else
          bitmap = Bitmap.crop(bitmap_ab, {0, row}, width, height)
          {[bitmap], {bitmap_ab, row + 1}}
        end
      end,
      fn _ -> nil end
    )
  end
end
