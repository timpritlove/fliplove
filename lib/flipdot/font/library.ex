defmodule Flipdot.Font.Library do
  @moduledoc """
  Font library process. Read and parse all avaiable fonts from disk and
  make them available.
  """
  use GenServer
  alias Flipdot.Font.Parser
  require Logger

  @topic "font_library_update"
  defstruct fonts: [], task_supervisor: nil

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def topic, do: @topic

  def init(_) do
    # Start with built-in fonts
    initial_fonts = [
      Flipdot.Font.Fonts.SpaceInvaders.get(),
      Flipdot.Font.Fonts.Flipdot.get()
    ]

    {:ok, task_supervisor} = Task.Supervisor.start_link()

    state = %__MODULE__{fonts: initial_fonts, task_supervisor: task_supervisor}
    {:ok, state, {:continue, :schedule_font_loading}}
  end

  def handle_continue(:schedule_font_loading, state) do
    font_dir = Path.join([Flipdot.static_dir(), "fonts"])

    # Schedule parsing tasks for each font file
    File.ls!(font_dir)
    |> Enum.filter(fn file_name -> String.ends_with?(file_name, ".bdf") end)
    |> Enum.each(fn font_file ->
      path = Path.join([font_dir, font_file])
      Task.Supervisor.async_nolink(state.task_supervisor, Parser, :parse_font, [path])
    end)

    {:noreply, state}
  end

  # Handle successful font parsing
  def handle_info({ref, parsed_font}, state) when is_reference(ref) do
    # Flush the DOWN message
    Process.demonitor(ref, [:flush])

    new_state = %{state | fonts: [parsed_font | state.fonts]}
    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, :font_library_update)

    {:noreply, new_state}
  end

  # Handle failed parsing tasks
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.error("Font parsing failed: #{inspect(reason)}")
    {:noreply, state}
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
    case Enum.find(state.fonts, fn font -> font.name == font_name end) do
      nil ->
        Logger.warning("Font #{font_name} not found, falling back to default font")
        # Fall back to first built-in font if requested font not found
        [default_font | _] = state.fonts
        {:reply, default_font, state}
      font ->
        {:reply, font, state}
    end
  end
end
