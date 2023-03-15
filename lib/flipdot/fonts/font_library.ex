defmodule Flipdot.Font.Library do
  @moduledoc """
  Font library process. Read and parse all avaiable fonts from disk and
  make them available.
  """
  use GenServer
  alias Flipdot.Font.Parser

  @topic "font_library_update"
  defstruct fonts: []

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def topic, do: @topic

  def init(state) do
    {:ok, state, {:continue, :read_fonts}}
  end

  def handle_continue(:read_fonts, state) do
    font_dir = Path.join([Flipdot.static_dir(), "fonts"])

    font_files =
      File.ls!(font_dir)
      |> Enum.filter(fn file_name -> String.ends_with?(file_name, ".bdf") end)

    parse_tasks =
      font_files
      |> Enum.map(fn font_file ->
        path = Path.join([font_dir, font_file])
        Task.async(__MODULE__, :parse_font, [path])
      end)

    fonts = Task.await_many(parse_tasks, 30_000)

    fonts = [Flipdot.Font.Fonts.SpaceInvaders.get() | fonts]
    fonts = [Flipdot.Font.Fonts.Flipdot.get() | fonts]

    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, :font_library_update)
    {:noreply, %{state | fonts: fonts}}
  end

  def get_fonts() do
    GenServer.call(__MODULE__, :get_fonts)
  end

  def get_font_by_name(font_name) do
    GenServer.call(__MODULE__, {:get_font_by_name, font_name})
  end

  # server functions

  def handle_call(:get_fonts, _, state) do
    {:reply, state.fonts, state}
  end

  def handle_call({:get_font_by_name, font_name}, _, state) do
    [font] = state.fonts |> Enum.filter(fn font -> font.name == font_name end)
    {:reply, font, state}
  end

  def parse_font(path) do
    {:ok, [font], _, _, _, _} = path |> File.read!() |> Parser.parse_bdf()
    font
  end
end
