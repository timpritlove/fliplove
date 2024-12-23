defmodule Flipdot.Experimental.Letterbox do
  alias Flipdot.Bitmap
  alias Flipdot.Bitmap.Transition
  alias Flipdot.Font.Renderer

  @transition_ms 100
  @still_ms 1_000

  def render_tla_movie(text) do
    font = Flipdot.Font.Fonts.Letterbox.get()
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

    frames = Transition.push_up(from, to)
    |> Enum.map(fn frame -> {@transition_ms, frame} end)

    frames ++ render_transition(remaining_letters, font)
  end

  def render_letter(char, font) do
    Renderer.render_text(Bitmap.new(8, 8), {0, 0}, font, [char])
  end
end
