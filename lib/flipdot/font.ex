defmodule Flipdot.Font do
  defstruct [:name, :properties, :characters]

  defimpl Inspect, for: Flipdot.Font do
    def inspect(font, _opts) do
      "FONT: " <> font.name <> "\n" <> Bitmap.to_text(font.character[?a].bitmap)
    end
  end
end
