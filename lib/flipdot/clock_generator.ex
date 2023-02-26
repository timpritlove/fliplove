defmodule Flipdot.ClockGenerator do
  @moduledoc """
  Generate clock image for display
  """
  use GenServer
  alias Flipdot.DisplayState

  @font_file "data/fonts/x11/helvB12.bdf"

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    font = FontRenderer.parse_font(@font_file)
    {:ok, Map.put(state, :font, font)}
  end

  def start_generator() do
    GenServer.call(__MODULE__, :start)
  end

  def stop_generator() do
    GenServer.call(__MODULE__, :stop)
  end

  # server functions

  @impl true
  def handle_call(:start, _, state) do
    {:ok, timer} = :timer.send_interval(250, self(), :tick)

    {:reply, :ok, state  |> Map.put(:timer, timer) }
  end

  @impl true
  def handle_call(:stop, _, state) do
    state =
      if Map.has_key?(state, :timer) do
        {:ok, :cancel} = :timer.cancel(state.timer)
        Map.delete(state, :timer)
      else
        state
      end

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    bitmap = DisplayState.get()

    {w,h} = Bitmap.dimensions(bitmap)

    timestring =
      Calendar.strftime(NaiveDateTime.utc_now(), "%c", preferred_datetime: "%H:%M:%S Uhr")

      Bitmap.new(w,h)
      |> FontRenderer.render_text(3, 2, state.font, timestring)
      |> DisplayState.set()
      {:noreply, state}
  end
end
