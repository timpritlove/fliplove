defmodule Flipdot.Composer.MazeSolver do
  @moduledoc """
  Show and solve a maze on the flipboard
  """
  use GenServer
  alias Flipdot.Display
  require Logger

  @registry Flipdot.Composer.Registry

  @frame_delay 500
  @maze_delay 5_000

  defstruct maze_stream: nil

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # server functions

  @impl true
  def init(state) do
    Logger.info("Starting Maze Solver...")
    Registry.register(@registry, :running_composer, :maze_solver)

    maze_stream = new_maze_stream()

    Process.send_after(self(), :next_frame, @maze_delay)
    {:ok, %{state | maze_stream: maze_stream}}
  end

  defp new_maze_stream do
    width = make_odd(Display.width())
    height = make_odd(Display.height())
    maze = Bitmap.Maze.generate_maze(width, height)
    Display.set(maze)
    Bitmap.Maze.solve_maze(maze, mode: :parallel)
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Maze Solver has been shut down.")
  end

  @impl true
  def handle_info(:next_frame, state) do
    maze_stream =
      case Enum.take(state.maze_stream, 1) do
        [bitmap] ->
          Display.set(bitmap)
          Process.send_after(self(), :next_frame, @frame_delay)
          Stream.drop(state.maze_stream, 1)

        [] ->
          Process.send_after(self(), :new_maze_stream, @maze_delay)
          []
      end

    {:noreply, %{state | maze_stream: maze_stream}}
  end

  def handle_info(:new_maze_stream, state) do
    new_maze_stream = new_maze_stream()
    Process.send_after(self(), :next_frame, @maze_delay)
    {:noreply, %{state | maze_stream: new_maze_stream }}
  end

  # Helper function to ensure dimensions are odd
  defp make_odd(n) when rem(n, 2) == 0, do: n - 1
  defp make_odd(n), do: n
end
