defmodule Flipdot.Dashboard do
  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use GenServer
  alias Flipdot.DisplayState
  alias Flipdot.Font.Renderer
  alias Flipdot.Font.Library
  alias Flipdot.Weather

  defstruct font: nil, timer: nil, time: nil, weather: nil, bitmap: nil

  @font "flipdot"

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    font = Library.get_font_by_name(@font)
    time = get_time_string()
    bitmap = compose_dashboard()

    {:ok, %{state | bitmap: bitmap, font: font, time: time}}
  end

  def start_dashboard() do
    GenServer.call(__MODULE__, :start_dashboard)
  end

  def stop_dashboard() do
    GenServer.call(__MODULE__, :stop_dashboard)
  end

  # server functions

  @impl true
  def handle_call(:start_dashboard, _, state) do
    {:ok, timer} = :timer.send_interval(250, self(), :update_dashboard)

    {:reply, :ok, %{state | timer: timer}}
  end

  @impl true
  def handle_call(:stop_dashboard, _, state) do
    state =
      if state.timer do
        {:ok, :cancel} = :timer.cancel(state.timer)
        %{state | timer: nil}
      else
        state
      end

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:update_dashboard, state) do
    time = get_time_string()

    if time != state.time do
      DisplayState.get() |> render_text(state.font, time) |> DisplayState.set()
    end

    {:noreply, %{state | time: time}}
  end

  # helper functions

  defp get_time_string do
    DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%H:%M")
  end

  defp compose_dashboard do
    Bitmap.new(DisplayState.width(), DisplayState.height())
  end

  defp render_text(bitmap, font, text) do
    rendered_text =
      Bitmap.new(1000, 1000)
      |> Renderer.render_text({10, 10}, font, text)
      |> Bitmap.clip()

    Bitmap.new(bitmap.meta.width, bitmap.meta.height)
    |> Bitmap.overlay(
      rendered_text,
      cursor_x: div(bitmap.meta.width - rendered_text.meta.width, 2),
      cursor_y: div(bitmap.meta.height - rendered_text.meta.height, 2)
    )
    |> Bitmap.overlay(
      Bitmap.frame(
        DisplayState.width(),
        DisplayState.height()
      )
    )
  end
end
