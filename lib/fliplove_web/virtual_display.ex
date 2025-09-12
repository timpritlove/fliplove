defmodule FliploveWeb.VirtualDisplay do
  @moduledoc """
  Virtual flipdot display simulation for web interface.

  This GenServer provides a virtual representation of the flipdot display
  that can be viewed through the web interface. It simulates the column-by-column
  update behavior of real flipdot hardware and broadcasts updates via PubSub.

  ## Features
  - Column-by-column update simulation
  - Real-time web display updates via PubSub
  - Configurable update delays to match hardware
  - Bitmap state management and transitions

  The virtual display allows testing and demonstration of flipdot content
  without requiring physical hardware.
  """
  use GenServer
  alias Fliplove.Bitmap
  require Logger

  # Column update delay in milliseconds
  @update_delay 10

  defmodule State do
    @moduledoc """
    Internal state structure for the virtual display GenServer.

    Tracks the current and target bitmaps, update progress, and timing configuration.
    """
    defstruct [:current_bitmap, :target_bitmap, :current_column, :width, :height, :timer_ref, delay_enabled: false]
  end

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Fliplove.PubSub, topic())
  end

  def get_bitmap do
    GenServer.call(__MODULE__, :get_bitmap)
  end

  def update_bitmap(new_bitmap) do
    GenServer.cast(__MODULE__, {:update_bitmap, new_bitmap})
  end

  def set_delay_enabled(enabled) do
    GenServer.cast(__MODULE__, {:set_delay_enabled, enabled})
  end

  def get_delay_enabled do
    GenServer.call(__MODULE__, :get_delay_enabled)
  end

  # Server callbacks

  @impl GenServer
  def init(_opts) do
    width = Fliplove.Driver.width()
    height = Fliplove.Driver.height()
    initial_bitmap = Bitmap.new(width, height)

    state = %State{
      current_bitmap: initial_bitmap,
      target_bitmap: initial_bitmap,
      current_column: nil,
      width: width,
      height: height,
      timer_ref: nil,
      delay_enabled: false
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_bitmap, _from, state) do
    {:reply, state.current_bitmap, state}
  end

  @impl GenServer
  def handle_call(:get_delay_enabled, _from, state) do
    {:reply, state.delay_enabled, state}
  end

  @impl GenServer
  def handle_cast({:set_delay_enabled, enabled}, state) do
    {:noreply, %{state | delay_enabled: enabled}}
  end

  @impl GenServer
  def handle_cast({:update_bitmap, new_bitmap}, state) do
    # Cancel any ongoing update
    if state.timer_ref do
      Process.cancel_timer(state.timer_ref)
    end

    if state.delay_enabled do
      # Update with delay
      state = %{state | target_bitmap: new_bitmap, current_column: 0, timer_ref: nil}
      send(self(), :process_next_column)
      {:noreply, state}
    else
      # Update immediately
      broadcast_update(new_bitmap)
      {:noreply, %{state | current_bitmap: new_bitmap, target_bitmap: new_bitmap, current_column: nil, timer_ref: nil}}
    end
  end

  @impl GenServer
  def handle_info(:process_next_column, state) do
    if state.current_column < state.width do
      {new_state, updated} = process_columns_until_update(state)

      # Broadcast the update
      broadcast_update(new_state.current_bitmap)

      # Schedule next update if needed
      new_state =
        if updated && new_state.current_column < state.width do
          timer_ref = Process.send_after(self(), :process_next_column, @update_delay)
          %{new_state | timer_ref: timer_ref}
        else
          %{new_state | timer_ref: nil}
        end

      {:noreply, new_state}
    else
      {:noreply, %{state | timer_ref: nil}}
    end
  end

  # Private functions

  defp topic, do: "virtual_display"

  defp broadcast_update(bitmap) do
    Phoenix.PubSub.broadcast(Fliplove.PubSub, topic(), {:virtual_display_updated, bitmap})
  end

  defp process_columns_until_update(state) do
    process_columns_until_update(state, false)
  end

  defp process_columns_until_update(state, _updated) when state.current_column >= state.width do
    {state, false}
  end

  defp process_columns_until_update(state, updated) do
    if column_needs_update?(state, state.current_column) do
      # Update this column and stop
      new_state = update_column(state, state.current_column)
      {%{new_state | current_column: state.current_column + 1}, true}
    else
      # Skip this column and continue to the next
      process_columns_until_update(
        %{state | current_column: state.current_column + 1},
        updated
      )
    end
  end

  defp column_needs_update?(state, x) do
    Enum.any?(0..(state.height - 1), fn y ->
      Bitmap.get_pixel(state.current_bitmap, {x, y}) != Bitmap.get_pixel(state.target_bitmap, {x, y})
    end)
  end

  defp update_column(state, x) do
    new_bitmap =
      Enum.reduce(0..(state.height - 1), state.current_bitmap, fn y, bitmap ->
        target_value = Bitmap.get_pixel(state.target_bitmap, {x, y})
        Bitmap.set_pixel(bitmap, {x, y}, target_value)
      end)

    %{state | current_bitmap: new_bitmap}
  end
end
