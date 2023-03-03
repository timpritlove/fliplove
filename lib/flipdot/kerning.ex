defmodule Flipdot.Kerning do
  @kerning %{
    "-Adobe-Helvetica-Bold-O-Normal--17-120-100-100-P-92-ISO8859-1" => %{
      'lu' => -1,
      'le' => -1,
      'nu' => -1,
      'ep' => -1,
      'es' => -1,
      'do' => -1,
      'ol' => -1,
      'ox' => -1,
      'sh' => -1,
      'ju' => -1,
      'br' => -1,
      'th' => -1,
      'qu' => -1,
      'tg' => -1,
      'st' => -1,
      'lt' => -1,
      'ui' => -1,
      'wn' => -1,
      'ov' => -1,
      'ps' => -1,
      'zi' => -1,
      'er' => -1,
      'Li' => -1,
      'li' => -1,
      'in' => -1,
      'ot' => -1
    }
  }

  def get_kerning(font_name, pair) do
    case @kerning[font_name][pair] do
      nil -> 0
      kerning -> kerning
    end
  end
end
