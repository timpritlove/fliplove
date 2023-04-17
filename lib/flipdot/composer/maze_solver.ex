defmodule Flipdot.Composer.MazeSolver do
  @moduledoc """
  Show and solve a maze on the flipboard
  """
  use GenServer
  alias ElixirLS.LanguageServer.Experimental.Protocol.Types.CodeAction.Disabled
  alias Flipdot.Display
  require Logger

  @registry Flipdot.Composer.Registry

  defstruct maze_stream: nil

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # server functions

  @impl true
  def init(state) do
    Registry.register(@registry, :running_composer, :maze_solver)

    maze = Bitmap.Maze.generate_maze(Display.width(), Display.width() - 1)
    Display.set(maze)

    maze_stream = Bitmap.Maze.solve_maze(maze, mode: :parallel)

    Process.send_after(self(), :next_frame, 1_000)
    Logger.debug("Maze Solver has been started.")
    {:ok, %{state | maze_stream: maze_stream}}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.debug("Shutting down Maze Solver.")
  end

  @impl true
  def handle_info(:next_frame, state) do
    maze_stream =
      case Enum.take(state.maze_stream, 1) do
        [bitmap] ->
          Display.set(bitmap)
          Process.send_after(self(), :next_frame, 100)
          Stream.drop(state.maze_stream, 1)

        [] ->
          maze = Bitmap.Maze.generate_maze(Display.width(), Display.height())
          Display.set(maze)
          Bitmap.Maze.solve_maze(maze, mode: :parallel)
          Process.send_after(self(), :next_frame, 5_000)
      end

    {:noreply, %{state | maze_stream: maze_stream}}
  end
end
