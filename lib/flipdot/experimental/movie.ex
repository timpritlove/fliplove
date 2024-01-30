defmodule Flipdot.Experimental.Movie do
  alias Flipdot.Display

  def movie_to_display(movie) do
    Enum.each(movie, fn {ms, frame} ->
      Display.set(frame)
      Process.sleep(ms)
    end)
  end
end
