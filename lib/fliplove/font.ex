defmodule Fliplove.Font do
  @moduledoc """
  Represents a BDF font with its characters and properties.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          version: String.t() | nil,
          properties: map(),
          # Map of encoding to character data
          characters: %{optional(integer) => map()},
          # Font bounding box
          fbb_x: integer() | nil,
          fbb_y: integer() | nil,
          fbb_x_off: integer() | nil,
          fbb_y_off: integer() | nil,
          # Font size and resolution
          size: integer() | nil,
          xres: integer() | nil,
          yres: integer() | nil
        }

  defstruct [:name, :version, :properties, :characters, :fbb_x, :fbb_y, :fbb_x_off, :fbb_y_off, :size, :xres, :yres]

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

  @doc """
  Returns the number of characters in the font.
  """
  @spec character_count(t()) :: non_neg_integer()
  def character_count(%__MODULE__{characters: chars}) do
    map_size(chars)
  end

  @doc """
  Returns a list of all character encodings in the font.
  """
  @spec encodings(t()) :: [integer()]
  def encodings(%__MODULE__{characters: chars}) do
    Map.keys(chars)
  end

  @doc """
  Returns a list of all character names in the font.
  """
  @spec character_names(t()) :: [String.t()]
  def character_names(%__MODULE__{characters: chars}) do
    chars
    |> Map.values()
    |> Enum.map(& &1.name)
    |> Enum.sort()
  end

  @doc """
  Checks if the font contains a character with the given encoding.
  """
  @spec has_encoding?(t(), integer()) :: boolean()
  def has_encoding?(%__MODULE__{characters: chars}, encoding) do
    Map.has_key?(chars, encoding)
  end

  @doc """
  Checks if the font contains a character with the given name.
  """
  @spec has_character?(t(), String.t()) :: boolean()
  def has_character?(font, name) do
    get_char_by_name(font, name) != nil
  end

  @doc """
  Returns basic ASCII characters (32-126) that are available in the font.
  """
  @spec ascii_characters(t()) :: %{optional(integer) => map()}
  def ascii_characters(%__MODULE__{characters: chars}) do
    chars
    |> Enum.filter(fn {encoding, _char} -> encoding >= 32 and encoding <= 126 end)
    |> Enum.into(%{})
  end

  @doc """
  Returns font metrics information if available.
  """
  @spec metrics(t()) :: map()
  def metrics(%__MODULE__{} = font) do
    %{
      character_count: character_count(font),
      font_bounding_box: %{
        width: Map.get(font, :fbb_x),
        height: Map.get(font, :fbb_y),
        x_offset: Map.get(font, :fbb_x_off),
        y_offset: Map.get(font, :fbb_y_off)
      },
      size: Map.get(font, :size),
      resolution: %{
        x: Map.get(font, :xres),
        y: Map.get(font, :yres)
      }
    }
  end

  defimpl Inspect, for: Fliplove.Font do
    def inspect(font, _opts) do
      "# %Font{}: \"#{font.name}\""
    end
  end
end
