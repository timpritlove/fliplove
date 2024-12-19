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
    # Start DynamicSupervisor
    Logger.debug("Starting DynamicSupervisor...")
    {:ok, _} = DynamicSupervisor.start_link(strategy: :one_for_one, name: @supervisor)
    Logger.info("DynamicSupervisor started")

    # Start composer based on environment variable with delay
    case System.get_env("FLIPDOT_COMPOSER") do
      nil ->
        Logger.debug("No default composer specified")

      composer_name ->
        composer_atom = String.to_existing_atom(composer_name)
        if Map.has_key?(@composers, composer_atom) do
          Logger.debug("Starting default composer in 1 second: #{composer_name}")
          Process.send_after(self(), {:start_default_composer, composer_atom}, 5000)
        else
          Logger.error("Invalid composer specified: #{composer_name}")
        end
    end

    {:ok, state}
  end

  # Add this handle_info callback to handle the delayed start
  def handle_info({:start_default_composer, composer}, state) do
    start_composer(composer)
    {:noreply, state}
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

    Logger.debug("Starting Composer #{composer}...")

    case DynamicSupervisor.start_child(@supervisor, child_spec) do
      {:ok, pid} ->
        Logger.info("Composer #{composer} started")
        Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_composer, running_composer()})
        {:ok, pid}

      {:error, reason} = error ->
        Logger.error("Starting the Composer #{composer} failed: #{inspect(reason)}")
        error
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
            Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:running_composer, nil})
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
