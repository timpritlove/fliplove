defmodule Fliplove.Experimental.Movie do
  @moduledoc """
  Experimental movie playback utilities.

  This module provides experimental functionality for playing movie sequences
  on flipdot displays. It handles frame timing and display updates for
  animated content.

  ## Features
  - Direct movie-to-display playback
  - Frame timing control
  - Simple animation loop handling

  ## Example
      movie = [{100, frame1}, {150, frame2}, {200, frame3}]
      Fliplove.Experimental.Movie.movie_to_display(movie)
  """
  alias Fliplove.Display

  def movie_to_display(movie) do
    Enum.each(movie, fn {ms, frame} ->
      Display.set(frame)
      Process.sleep(ms)
    end)
  end
end
