defmodule Fliplove.Apps.Symbols do
  alias Fliplove.Bitmap
  alias Fliplove.Display

  @moduledoc """
  Show random symbols from text files on the flipboard
  """
  use Fliplove.Apps.Base
  require Logger

  @symbols_dir "priv/static/symbols"
  @display_time 5_000
  @num_symbols 5

  defstruct all_symbols: nil, last_position: nil, current_symbols: []

  def init_app(_opts) do
    # Load all symbol files recursively
    all_symbols = load_symbols_from_dir(@symbols_dir)

    # Initialize with a full set of random symbols
    symbols = Enum.take_random(all_symbols, @num_symbols)

    # Calculate positions for even spacing
    total_symbols_width = Enum.reduce(symbols, 0, &(&1.width + &2))
    remaining_space = Display.width() - total_symbols_width
    spacing = div(remaining_space, @num_symbols - 1)

    # Position symbols with calculated spacing
    current_symbols =
      symbols
      |> Enum.reduce({[], 0}, fn symbol, {acc, x_pos} ->
        new_acc = [{symbol, x_pos} | acc]
        new_x = x_pos + symbol.width + spacing
        {new_acc, new_x}
      end)
      |> elem(0)
      |> Enum.reverse()

    # Initialize state with all required fields
    state = %__MODULE__{
      all_symbols: all_symbols,
      current_symbols: current_symbols,
      last_position: nil
    }

    # Render initial display
    render_display(state)
    :timer.send_after(@display_time, __MODULE__, :next_display)

    {:ok, state}
  end

  # server functions

  @impl Fliplove.Apps.Base
  def cleanup_app(_reason, _state) do
    Logger.debug("Symbols cleanup_app called")
    :ok
  end

  @impl true
  def handle_info(:next_display, state) do
    # Pick a random position to replace, excluding the last replaced position
    {old_symbol, position} =
      state.current_symbols
      |> Enum.reject(fn {_, pos} -> pos == state.last_position end)
      |> Enum.random()

    # Pick a new random symbol
    new_symbol = Enum.random(state.all_symbols)

    # Update the current symbols list, keeping the same position
    current_symbols =
      state.current_symbols
      |> Enum.map(fn
        {^old_symbol, pos} when pos == position -> {new_symbol, position}
        other -> other
      end)

    state = %{state | current_symbols: current_symbols, last_position: position}

    # Render the updated display
    render_display(state)
    :timer.send_after(@display_time, __MODULE__, :next_display)

    {:noreply, state}
  end

  # Helper to render the current symbols to the display
  defp render_display(state) do
    result = Bitmap.new(Display.width(), Display.height())

    Enum.reduce(state.current_symbols, result, fn {symbol, x_pos}, bitmap ->
      Bitmap.overlay(bitmap, symbol, cursor_x: x_pos)
    end)
    |> Display.set()

  end

  # Helper to recursively load symbols from a directory
  defp load_symbols_from_dir(dir) do
    dir
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      path = Path.join(dir, entry)

      cond do
        # If it's a directory, recursively load symbols from it
        File.dir?(path) ->
          load_symbols_from_dir(path)

        # If it's a .txt file, load it as a symbol
        String.ends_with?(entry, ".txt") ->
          [Bitmap.from_file(path)]

        # Otherwise ignore it
        true ->
          []
      end
    end)
  end
end
