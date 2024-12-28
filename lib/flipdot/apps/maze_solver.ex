defmodule Flipdot.Apps.MazeSolver do
  alias Flipdot.Bitmap
  alias Flipdot.Bitmap.Maze

  @moduledoc """
  Show and solve a maze on the flipboard
  """
  use Flipdot.Apps.Base
  alias Flipdot.Display
  require Logger

  @frame_delay 100
  @maze_delay 5_000

  defstruct maze_stream: nil

  def init_app(_opts) do
    maze_stream = new_maze_stream()

    Process.send_after(self(), :next_frame, @maze_delay)
    {:ok, %__MODULE__{maze_stream: maze_stream}}
  end

  defp new_maze_stream do
    width = make_odd(Display.width())
    height = make_odd(Display.height())
    maze = Maze.generate_maze(width, height)
    Display.set(maze)
    Maze.solve_maze(maze, mode: :parallel)
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Maze Solver has been shut down.")
  end

  @impl true
  def handle_info(:next_frame, state) do
    { maze_stream, next_event, delay } =
      case Enum.take(state.maze_stream, 1) do
        [bitmap] ->
          Display.set(bitmap)
          delay = case Enum.take(state.maze_stream, 2) do
            [_, next_bitmap] -> Bitmap.diff_count(bitmap, next_bitmap) * @frame_delay
            _ -> @frame_delay
          end
          { Stream.drop(state.maze_stream, 1), :next_frame, delay }

        [] ->
          { [], :new_maze_stream, @maze_delay }
      end


    Process.send_after(self(), next_event, delay)
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
