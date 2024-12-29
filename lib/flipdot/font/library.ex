defmodule Flipdot.Font.Library do
  @moduledoc """
  Font library process. Read and parse all avaiable fonts from disk and
  make them available.
  """
  use GenServer
  alias Flipdot.Font.Parser
  require Logger

  @topic "font_library_update"
  defstruct fonts: [], task_supervisor: nil, parsing_tasks: []

  def start_link(_state) do
    Logger.debug("Starting Font Library")
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def topic, do: @topic

  def init(_) do
    Logger.debug("Initializing Font Library")
    Process.flag(:trap_exit, true)

    # Start with built-in fonts
    initial_fonts = [
      Flipdot.Font.Fonts.SpaceInvaders.get(),
      Flipdot.Font.Fonts.Flipdot.get()
    ]
    Logger.debug("Loaded #{length(initial_fonts)} built-in fonts")

    {:ok, task_supervisor} = Task.Supervisor.start_link()
    Logger.debug("Started Task Supervisor")

    state = %__MODULE__{fonts: initial_fonts, task_supervisor: task_supervisor, parsing_tasks: []}
    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, :font_library_update)

    {:ok, state, {:continue, :schedule_font_loading}}
  end

  def handle_continue(:schedule_font_loading, state) do
    font_dir = Path.join([Flipdot.static_dir(), "fonts"])
    Logger.debug("Loading fonts from #{font_dir}")

    # Schedule parsing tasks for each font file
    parsing_tasks =
      case File.ls(font_dir) do
        {:ok, files} ->
          font_files = Enum.filter(files, fn file_name -> String.ends_with?(file_name, ".bdf") end)
          Logger.debug("Found #{length(font_files)} .bdf files")

          Enum.map(font_files, fn font_file ->
            path = Path.join([font_dir, font_file])
            Task.Supervisor.async_nolink(state.task_supervisor, Parser, :parse_font, [path])
          end)

        {:error, reason} ->
          Logger.error("Failed to list font directory: #{inspect(reason)}")
          []
      end

    {:noreply, %{state | parsing_tasks: parsing_tasks}}
  end

  # Handle successful font parsing
  def handle_info({ref, parsed_font}, state) when is_reference(ref) do
    # Flush the DOWN message
    Process.demonitor(ref, [:flush])

    # Remove the completed task from parsing_tasks
    parsing_tasks = Enum.reject(state.parsing_tasks, fn task -> task.ref == ref end)

    new_state = %{state |
      fonts: [parsed_font | state.fonts],
      parsing_tasks: parsing_tasks
    }

    # Only broadcast if we successfully parsed a font
    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, :font_library_update)

    {:noreply, new_state}
  end

  # Handle failed parsing tasks
  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    Logger.error("Font parsing failed: #{inspect(reason)}")

    # Remove the failed task from parsing_tasks
    parsing_tasks = Enum.reject(state.parsing_tasks, fn task -> task.ref == ref end)
    {:noreply, %{state | parsing_tasks: parsing_tasks}}
  end

  def handle_info(msg, state) do
    Logger.warning("Unexpected message in Font Library: #{inspect(msg)}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.warning("Font Library terminating: #{inspect(reason)}")
    # Cancel any ongoing parsing tasks
    Enum.each(state.parsing_tasks, fn task ->
      Task.Supervisor.terminate_child(state.task_supervisor, task.pid)
    end)
  end

  def get_fonts() do
    GenServer.call(__MODULE__, :get_fonts)
  end

  def get_font_by_name(font_name) do
    case GenServer.call(__MODULE__, {:get_font_by_name, font_name}) do
      nil -> Flipdot.Font.Fonts.Flipdot.get()  # Fallback to default font
      font -> font
    end
  end

  # server functions

  def handle_call(:get_fonts, _from, state) do
    {:reply, state.fonts, state}
  end

  def handle_call({:get_font_by_name, font_name}, _, state) do
    case Enum.find(state.fonts, fn font -> font.name == font_name end) do
      nil ->
        Logger.warning("Font #{font_name} not found, falling back to default font")
        {:reply, nil, state}
      font ->
        {:reply, font, state}
    end
  end
end
