defmodule Flipdot.App do
  use GenServer
  require Logger

  @registry Flipdot.App.Registry
  @supervisor Flipdot.App.DynamicSupervisor

  @topic "app"

  @apps %{
    dashboard: Flipdot.App.Dashboard,
    slideshow: Flipdot.App.Slideshow,
    maze_solver: Flipdot.App.MazeSolver,
    symbols: Flipdot.App.Symbols
  }

  def topic, do: @topic

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
        Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_app, running_app()})
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
        ref = Process.monitor(pid)
        DynamicSupervisor.terminate_child(@supervisor, pid)

        receive do
          {:DOWN, ^ref, :process, ^pid, reason} ->
            Logger.debug("App has stopped #{reason}")
            Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_app, nil})
            :ok
        after
          5000 ->
            Process.demonitor(ref)
            {:error, :app_stop_timeout}
        end
    end
  end
end
