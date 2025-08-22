defmodule Fliplove.Bitmap.GameOfLife do
  @moduledoc """
  Conway's Game of Life implementation for bitmap displays.

  This module implements the classic cellular automaton "Game of Life"
  on bitmap data, creating evolving patterns suitable for flipdot displays.

  ## Rules
  1. Any live cell with fewer than two live neighbors dies (underpopulation)
  2. Any live cell with two or three live neighbors lives on to the next generation
  3. Any live cell with more than three live neighbors dies (overpopulation)
  4. Any dead cell with exactly three live neighbors becomes a live cell (reproduction)

  ## Example
      # Start with a bitmap pattern
      bitmap = Fliplove.Bitmap.from_lines_of_text([
        "     ",
        " *** ",
        "     "
      ])

      # Apply one generation
      next_gen = Fliplove.Bitmap.GameOfLife.game_of_life(bitmap)
  """
  alias Fliplove.Bitmap

  @doc """
  Apply Game of Life Algorithm to bitmap
  - a living cell surrounded by less than 2 living cells will die.
  - a living cell surrounded by more than 3 living cells will also die.
  - a dead cell surrounded by 3 living cells will be reborn.
  """
  def game_of_life(bitmap) do
    {width, height} = Bitmap.dimensions(bitmap)

    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{} do
        number_of_neighbors =
          for dx <- [x - 1, x, x + 1],
              dy <- [y - 1, y, y + 1],
              dx >= 0,
              dy >= 0,
              dx < width,
              dy < height,
              not (dx == x and dy == y),
              Bitmap.get_pixel(bitmap, {dx, dy}) == 1,
              reduce: 0 do
            count -> count + 1
          end

        old_cell = Bitmap.get_pixel(bitmap, {x, y})

        new_cell =
          cond do
            old_cell == 1 and number_of_neighbors < 2 -> 0
            old_cell == 1 and number_of_neighbors > 3 -> 0
            old_cell == 0 and number_of_neighbors == 3 -> 1
            true -> old_cell
          end

        {{x, y}, new_cell}
      end

    Bitmap.new(width, height, matrix)
  end

  def game_of_life_stream(bitmap) do
    Bitmap.filter_stream(bitmap, &game_of_life/1)
  end
end
