defmodule Flipdot.Font.Kerning do
  @kerning %{
    "-Adobe-Helvetica-Bold-O-Normal--17-120-100-100-P-92-ISO8859-1" => %{
      17 => %{
        "We" => -1,
        "lu" => -1,
        "le" => -1,
        "nu" => -1,
        "ep" => -1,
        "es" => -1,
        "do" => -1,
        "ol" => -1,
        "ox" => -1,
        "sh" => -1,
        "ju" => -1,
        "br" => -1,
        "th" => -1,
        "qu" => -1,
        "tg" => -1,
        "st" => -1,
        "lt" => -1,
        "ui" => -1,
        "wn" => -1,
        "ov" => -1,
        "ps" => -1,
        "zi" => -1,
        "er" => -1,
        "Li" => -1,
        "li" => -1,
        "in" => -1,
        "ot" => -1
      }
    },
    "-Adobe-Helvetica-Medium-O-Normal--14-100-100-100-P-78-ISO8859-1" => %{
      14 => %{
        "Li" => -1,
        "ic" => -1,
        "es" => -1,
        "ht" => -1,
        "al" => -1
      }
    },
    "space-invaders" => %{
      7 => %{}
    },
    "flipdot" => %{
      7 => %{
        "lt" => -1
      }
    }
  }

  def get_kerning(font, pair) do
    case @kerning[font.name][font.properties.pixel_size][pair] do
      nil -> 0
      kerning -> kerning
    end
  end
end
