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

    {:reply, :ok, Map.put(state, :timer, timer)}
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

    render_time(bitmap, state.font) |> DisplayState.set()

    {:noreply, state}
  end

  def render_time(bitmap, font) do
    time_string =
      DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
      |> Calendar.strftime("%c", preferred_datetime: "%H:%M Uhr")

    rendered_text =
      Bitmap.new(1000, 1000)
      |> FontRenderer.render_text(10, 10, font, time_string)
      |> Bitmap.clip()

    Bitmap.new(bitmap.meta.width, bitmap.meta.height)
    |> Bitmap.overlay(
      rendered_text,
      cursor_x: div(bitmap.meta.width - rendered_text.meta.width, 2),
      cursor_y: div(bitmap.meta.height - rendered_text.meta.height, 2)
    )
    |> Bitmap.overlay(Bitmap.frame(115, 16))
  end
end
