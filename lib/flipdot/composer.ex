defmodule Flipdot.Composer do
  use GenServer
  require Logger

  @registry Flipdot.Composer.Registry
  @supervisor Flipdot.Composer.DynamicSupervisor

  @topic "composer"

  @composers %{
    dashboard: Flipdot.Composer.Dashboard,
    slideshow: Flipdot.Composer.Slideshow,
    maze_solver: Flipdot.Composer.MazeSolver
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    {:ok, _pid} = Registry.start_link(keys: :unique, name: @registry)
    Logger.debug("Starting DynamicSupervisor")
    {:ok, _pid} = DynamicSupervisor.start_link(strategy: :one_for_one, name: @supervisor)

    # Start the dashboard composer by default
    start_composer(:dashboard)

    {:ok, state}
  end

  # client functions

  def topic, do: @topic

  def start_composer(composer) do
    case Registry.lookup(@registry, :running_composer) do
      [] ->
        start_new_composer(composer)

      [{_pid, running_composer}] when running_composer == composer ->
        {:ok, :composer_already_running}

      [_] ->
        case stop_composer() do
          :ok ->
            start_new_composer(composer)

          {:error, _} = error ->
            error
        end
    end
  end

  def running_composer() do
    case Registry.lookup(@registry, :running_composer) do
      [{_pid, running_composer}] -> running_composer
      [] -> nil
    end
  end

  defp start_new_composer(composer) do
    child_spec = %{
      id: @composers[composer],
      start: {@composers[composer], :start_link, [nil]},
      restart: :transient
    }

    Logger.debug("Starting Composer")

    case DynamicSupervisor.start_child(@supervisor, child_spec) do
      {:ok, _} ->
        Logger.debug("Composer started")
        Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_composer, running_composer()})

      {:error, reason} ->
        Logger.debug("Starting the Composer failed (#{inspect(reason)})")
    end
  end

  def stop_composer() do
    case Registry.lookup(@registry, :running_composer) do
      [{pid, _}] ->
        ref = Process.monitor(pid)
        :ok = GenServer.stop(pid, :normal)

        receive do
          {:DOWN, ^ref, :process, ^pid, reason} ->
            Logger.debug("Composer has stopped #{reason}")
            Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_composer, running_composer()})

            :ok
        after
          5_000 ->
            {:error, :composer_stop_timeout}
        end

      [] ->
        :ok
    end
  end
end
