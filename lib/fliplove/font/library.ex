defmodule Fliplove.Font.Library do
  @moduledoc """
  Font library process. Read and parse all avaiable fonts from disk and
  make them available.
  """
  use GenServer
  alias Fliplove.Font.Parser
  alias Fliplove.Font.Fonts
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

    # Start with built-in fonts - wrap in try/catch for fatal error logging
    initial_fonts =
      try do
        fonts = [
          Fonts.SpaceInvaders.get(),
          Fonts.Flipdot.get(),
          Fonts.FlipdotCondensed.get()
        ]

        Logger.debug("Loaded #{length(fonts)} built-in fonts")
        fonts
      rescue
        error ->
          Logger.error("FATAL: Failed to load built-in fonts: #{inspect(error)}")
          Logger.error("FATAL: Font Library cannot start without built-in fonts")
          Logger.error("FATAL: This will cause the Font Library to terminate")
          reraise error, __STACKTRACE__
      catch
        :exit, reason ->
          Logger.error("FATAL: Exit while loading built-in fonts: #{inspect(reason)}")
          Logger.error("FATAL: Font Library cannot start without built-in fonts")
          exit(reason)
      end

    {:ok, task_supervisor} = Task.Supervisor.start_link()

    state = %__MODULE__{fonts: initial_fonts, task_supervisor: task_supervisor, parsing_tasks: []}
    Phoenix.PubSub.broadcast(Fliplove.PubSub, @topic, :font_library_update)

    {:ok, state, {:continue, :schedule_font_loading}}
  end

  def handle_continue(:schedule_font_loading, state) do
    font_dir = Path.join([Fliplove.static_dir(), "fonts"])
    Logger.debug("Loading fonts from #{font_dir}")

    # Schedule parsing tasks for each font file
    parsing_tasks =
      case File.ls(font_dir) do
        {:ok, files} ->
          font_files = Enum.filter(files, fn file_name -> String.ends_with?(file_name, ".bdf") end)
          Logger.debug("Found #{length(font_files)} .bdf files")

          if Enum.empty?(font_files) do
            Logger.warning("No .bdf font files found in #{font_dir}")
            Logger.info("Continuing with built-in fonts only")
            []
          else
            Enum.map(font_files, fn font_file ->
              path = Path.join([font_dir, font_file])
              Task.Supervisor.async_nolink(state.task_supervisor, Parser, :parse_font, [path])
            end)
          end

        {:error, reason} ->
          Logger.error("Failed to list font directory #{font_dir}: #{inspect(reason)}")
          Logger.info("Continuing with built-in fonts only")
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

    new_state = %{state | fonts: [parsed_font | state.fonts], parsing_tasks: parsing_tasks}

    # Only broadcast if we successfully parsed a font
    Phoenix.PubSub.broadcast(Fliplove.PubSub, @topic, :font_library_update)

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
    case reason do
      :normal ->
        Logger.info("Font Library terminating normally")

      :shutdown ->
        Logger.info("Font Library shutting down")

      {:shutdown, _} ->
        Logger.info("Font Library shutting down: #{inspect(reason)}")

      _ ->
        Logger.error("FATAL: Font Library terminating unexpectedly: #{inspect(reason)}")
        Logger.error("FATAL: This may cause dependent services to restart")
        Logger.error("FATAL: Font Library state at termination: #{inspect(state)}")
    end

    # Cancel any ongoing parsing tasks
    if state.parsing_tasks && length(state.parsing_tasks) > 0 do
      Logger.debug("Cancelling #{length(state.parsing_tasks)} ongoing font parsing tasks")

      Enum.each(state.parsing_tasks, fn task ->
        Task.Supervisor.terminate_child(state.task_supervisor, task.pid)
      end)
    end
  end

  def get_fonts() do
    GenServer.call(__MODULE__, :get_fonts)
  end

  def get_font_by_name(font_name) do
    case GenServer.call(__MODULE__, {:get_font_by_name, font_name}) do
      # Fallback to default font
      nil -> Fonts.Flipdot.get()
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
