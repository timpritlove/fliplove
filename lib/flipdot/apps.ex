defmodule Flipdot.Apps do
  use GenServer
  require Logger

  @registry Flipdot.Apps.Registry
  @supervisor Flipdot.Apps.DynamicSupervisor

  @apps %{
    dashboard: Flipdot.Apps.Dashboard,
    slideshow: Flipdot.Apps.Slideshow,
    maze_solver: Flipdot.Apps.MazeSolver,
    symbols: Flipdot.Apps.Symbols
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Start app based on environment variable with delay
    case System.get_env("FLIPDOT_APP") do
      nil ->
        Logger.debug("No default app specified")
      app_name ->
        app_atom = String.to_existing_atom(app_name)
        if Map.has_key?(@apps, app_atom) do
          Logger.debug("Starting default app in 1 second: #{app_name}")
          Process.send_after(self(), {:start_default_app, app_atom}, 5000)
        else
          Logger.error("Invalid app specified: #{app_name}")
        end
    end

    {:ok, nil}
  end

  def handle_info({:start_default_app, app}, state) do
    start_app(app)
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  @doc """
  Start a new app
  """
  def start_app(app) do
    case Registry.lookup(@registry, :running_app) do
      [] ->
        start_new_app(app)

      [{_pid, running_app}] when running_app == app ->
        {:ok, :app_already_running}

      _ ->
        case stop_app() do
          :ok -> start_new_app(app)
          error -> error
        end
    end
  end

  def running_app() do
    case Registry.lookup(@registry, :running_app) do
      [{_pid, running_app}] -> running_app
      [] -> nil
    end
  end

  defp start_new_app(app) do
    child_spec = %{
      id: @apps[app],
      start: {@apps[app], :start_link, [nil]},
      restart: :temporary
    }

    Logger.debug("Starting App #{app}...")

    case DynamicSupervisor.start_child(@supervisor, child_spec) do
      {:ok, _pid} ->
        Logger.info("App #{app} started")
        :ok

      {:error, reason} ->
        Logger.error("Starting the App #{app} failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def stop_app() do
    case Registry.lookup(@registry, :running_app) do
      [] ->
        :ok

      [{pid, _}] ->
        DynamicSupervisor.terminate_child(@supervisor, pid)
        :ok
    end
  end
end