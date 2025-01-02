defmodule Fliplove.Font do
  @moduledoc """
  Represents a BDF font with its characters and properties.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          properties: map(),
          # Map of encoding to character data
          characters: %{optional(integer) => map()}
        }

  defstruct [:name, :properties, :characters]

  @doc """
  Looks up a character by its encoding number.
  Returns nil if the character is not found.
  """
  @spec get_char_by_encoding(t(), integer) :: map() | nil
  def get_char_by_encoding(%__MODULE__{characters: chars}, encoding) do
    Map.get(chars, encoding)
  end

  @doc """
  Looks up a character by its name.
  Returns nil if no character with that name is found.
  """
  @spec get_char_by_name(t(), String.t()) :: map() | nil
  def get_char_by_name(%__MODULE__{characters: chars}, name) do
    Enum.find_value(chars, fn {_encoding, char} ->
      if char.name == name, do: char, else: nil
    end)
  end

  defimpl Inspect, for: Fliplove.Font do
    def inspect(font, _opts) do
      "# %Font{}: \"#{font.name}\""
    end
  end
end
