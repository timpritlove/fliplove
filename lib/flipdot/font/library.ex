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
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def topic, do: @topic

  def init(_) do
    Process.flag(:trap_exit, true)

    # Start with built-in fonts
    initial_fonts = [
      Flipdot.Font.Fonts.SpaceInvaders.get(),
      Flipdot.Font.Fonts.Flipdot.get()
    ]

    {:ok, task_supervisor} = Task.Supervisor.start_link()

    state = %__MODULE__{fonts: initial_fonts, task_supervisor: task_supervisor, parsing_tasks: []}
    {:ok, state, {:continue, :schedule_font_loading}}
  end

  def handle_continue(:schedule_font_loading, state) do
    font_dir = Path.join([Flipdot.static_dir(), "fonts"])

    # Schedule parsing tasks for each font file
    parsing_tasks =
      File.ls!(font_dir)
      |> Enum.filter(fn file_name -> String.ends_with?(file_name, ".bdf") end)
      |> Enum.map(fn font_file ->
        path = Path.join([font_dir, font_file])
        Task.Supervisor.async_nolink(state.task_supervisor, Parser, :parse_font, [path])
      end)

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
    try do
      GenServer.call(__MODULE__, :get_fonts)
    catch
      :exit, {:timeout, _} ->
        Logger.error("Timeout getting fonts, returning built-in fonts")
        [
          Flipdot.Font.Fonts.SpaceInvaders.get(),
          Flipdot.Font.Fonts.Flipdot.get()
        ]
      :exit, reason ->
        Logger.error("Error getting fonts: #{inspect(reason)}, returning built-in fonts")
        [
          Flipdot.Font.Fonts.SpaceInvaders.get(),
          Flipdot.Font.Fonts.Flipdot.get()
        ]
    end
  end

  def get_font_by_name(font_name) do
    try do
      GenServer.call(__MODULE__, {:get_font_by_name, font_name})
    catch
      :exit, {:timeout, _} ->
        Logger.error("Timeout getting font #{font_name}, returning default font")
        Flipdot.Font.Fonts.Flipdot.get()
      :exit, reason ->
        Logger.error("Error getting font #{font_name}: #{inspect(reason)}, returning default font")
        Flipdot.Font.Fonts.Flipdot.get()
    end
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
