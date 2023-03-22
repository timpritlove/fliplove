defmodule Flipdot.Dashboard do
  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use GenServer
  alias Flipdot.{DisplayState, Weather}
  alias Flipdot.Font.{Renderer, Library}
  require Logger
  # import Flipdot.PrettyDump

  defstruct font: nil, timer: nil, time: nil, weather: nil, bitmap: nil

  @font "flipdot"
  @clock_symbol 0xF017
  @wind_symbol 0xF72E

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    font = Library.get_font_by_name(@font)

    {:ok, %{state | font: font}}
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

    Logger.info("Dashboard has been started.")
    {:reply, :ok, %{state | timer: timer}}
  end

  @impl true
  def handle_call(:stop_dashboard, _, state) do
    Logger.info("Shutting down Dashboard.")

    state =
      if state.timer do
        {:ok, :cancel} = :timer.cancel(state.timer)
        Logger.info("Timer canceled.")
        %{state | timer: nil}
      else
        state
      end

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:update_dashboard, state) do
    state = update_dashboard(state)
    {:noreply, state}
  end

  # helper functions

  defp get_time_string do
    DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%H:%M")
  end

  defp update_dashboard(state) do
    time_string = get_time_string()
    weather = Weather.get_weather()

    bitmap = Bitmap.new(DisplayState.width(), DisplayState.height())

    # render temperature
    temperature = Weather.get_temperature()
    # pretty_dump(temperature, "temperature")
    temp_string = :erlang.float_to_binary(temperature / 1, decimals: 1) <> "°C"
    bitmap = place_text(bitmap, state.font, temp_string, :top, :left)

    # render rain
    # {rainfall_rate, rainfall_intensity} = Weather.get_rain()

    # bitmap =
    #   place_text(bitmap, state.font, "R #{rainfall_rate}  I #{rainfall_intensity}",
    #     align_vertically: :top,
    #     align_horizontally: :left
    #   )

    # render wind
    {_wind_speed, wind_force} = Weather.get_wind()

    # bitmap = place_text(bitmap, state.font, :erlang.float_to_binary(wind_speed, decimals: 1), :bottom, :left)
    bitmap = place_text(bitmap, state.font, "WS " <> Integer.to_string(wind_force), :bottom, :left)

    bitmap =
      Bitmap.overlay(bitmap, Weather.bitmap_48(16) |> Bitmap.crop_relative(115, 16, rel_x: :center, rel_y: :middle))

    # plot temperature hours

    # render time

    bitmap = place_text(bitmap, state.font, "#{[@clock_symbol]}", :top, :right)
    bitmap = place_text(bitmap, state.font, time_string, :bottom, :right)

    if bitmap != state.bitmap do
      DisplayState.set(bitmap)
    end

    %{state | time: time_string, weather: weather}
  end

  defp place_text(bitmap, font, text, align_vertically, align_horizontally) do
    rendered_text =
      Bitmap.new(1000, 1000)
      |> Renderer.render_text({10, 10}, font, text)
      |> Bitmap.clip()

    cursor_x =
      case align_horizontally do
        :left -> 0
        :center -> div(Bitmap.width(bitmap) - Bitmap.width(rendered_text), 2)
        :right -> Bitmap.width(bitmap) - Bitmap.width(rendered_text)
      end

    cursor_y =
      case align_vertically do
        :top -> Bitmap.height(bitmap) - Bitmap.height(rendered_text)
        :middle -> div(Bitmap.height(bitmap) - Bitmap.height(rendered_text), 2)
        :bottom -> 0
      end

    bitmap
    |> Bitmap.overlay(
      rendered_text,
      cursor_x: cursor_x,
      cursor_y: cursor_y
    )
  end
end
