defmodule Flipdot.Font do
  defstruct [:name, :properties, :characters]

  defimpl Inspect, for: Flipdot.Font do
    def inspect(font, _opts) do
      "# %Font{}: \"#{font.name}\""
    end
  end
end
