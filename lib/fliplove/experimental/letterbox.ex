defmodule Fliplove.Experimental.Letterbox do
  @moduledoc """
  Experimental letterbox-style text animations.

  This module provides experimental functionality for creating letterbox-style
  text animations with smooth transitions between characters or words.
  Uses the Letterbox font for cinematic text display effects.

  ## Features
  - Letter-by-letter text animation
  - Smooth transitions between characters
  - Configurable timing for transitions and display
  - TLA (Three Letter Acronym) movie rendering

  ## Example
      # Create animated text sequence
      Fliplove.Experimental.Letterbox.render_tla_movie("ABC")
  """
  alias Fliplove.Bitmap
  alias Fliplove.Bitmap.Transition
  alias Fliplove.Font.Renderer

  @transition_ms 100
  @still_ms 1_000

  def render_tla_movie(text) do
    font = Fliplove.Font.Fonts.Letterbox.get()
    letters = String.to_charlist(text)
    render_transition(letters, font)
  end

  def render_transition([letter], font) do
    frame = render_letter(letter, font)
    [{@still_ms, frame}]
  end

  def render_transition([from_char | remaining_letters], font) do
    from = render_letter(from_char, font)
    to = render_letter(hd(remaining_letters), font)

    frames =
      Transition.push_up(from, to)
      |> Enum.map(fn frame -> {@transition_ms, frame} end)

    frames ++ render_transition(remaining_letters, font)
  end

  def render_letter(char, font) do
    Renderer.render_text(Bitmap.new(8, 8), {0, 0}, font, [char])
  end
end
