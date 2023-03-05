defmodule Flipdot.FontLibrary do
  @moduledoc """
  Font library process. Read and parse all avaiable fonts from disk and
  make them available.
  """
  use GenServer

  @topic "font_library_update"
  defstruct fonts: nil, font_index: nil

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def topic, do: @topic

  def init(state) do
    {:ok, state, {:continue, :read_fonts}}
  end

  def handle_continue(:read_fonts, state) do
    font_dir = Flipdot.static_dir() <> "fonts/"

    parsed_fonts =
      File.ls!(font_dir)
      |> Enum.filter(fn file_name -> String.ends_with?(file_name, ".bdf") end)
      |> Enum.map(fn font_file ->
        parse_font(font_dir <> font_file)
      end)

    fonts =
      for font <- parsed_fonts, into: %{} do
        {font.name, font}
      end

    font_index =
      for font <- parsed_fonts do
        {
          font.name,
          Map.get(font.properties, :foundry, ""),
          Map.get(font.properties, :family_name, ""),
          Map.get(font.properties, :weight_name, ""),
          Map.get(font.properties, :slant, ""),
          Map.get(font.properties, :pixel_size, "")
        }
      end

    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:font_library_update, font_index})

    {:noreply, %{state | fonts: fonts, font_index: font_index}}
  end

  def get_font_index() do
    GenServer.call(__MODULE__, :get_font_index)
  end

  def get_font(font_name) do
    GenServer.call(__MODULE__, {:get_font, font_name})
  end

  def handle_call(:get_font_index, _, state) do
    {:reply, state.font_index, state}
  end

  def handle_call({:get_font, font_name}, _, state) do
    font = Map.get(state.fonts, font_name, nil)
    {:reply, font, state}
  end

  def parse_font(path) do
    {:ok, [font], _, _, _, _} = path |> File.read!() |> FontParser.parse_bdf()
    font
  end
end
