defmodule Flipdot.App.Dashboard do
  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use GenServer
  alias Phoenix.PubSub
  alias Flipdot.{Display, Weather}
  alias Flipdot.Font.{Renderer, Library}
  require Logger
  # import Flipdot.PrettyDump

  defstruct font: nil, bitmap: nil

  @registry Flipdot.App.Registry

  @font "flipdot"
  @clock_symbol 0xF017
  @ms_symbol 0xF018
  #  @wind_symbol 0xF72E

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # server functions

  @impl true
  def init(state) do
    Logger.info("Dashboard is starting...")
    Registry.register(@registry, :running_app, :dashboard)

    state = %{state | font: Library.get_font_by_name(@font)}
    update_dashboard(state)

    schedule_next_minute(:clock_timer)
    PubSub.subscribe(Flipdot.PubSub, Weather.topic())

    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Dashboard has been shut down.")
  end

  @impl true
  def handle_info(:clock_timer, state) do
    Logger.debug("Clock timer fired")
    update_dashboard(state)
    schedule_next_minute(:clock_timer)

    {:noreply, state}
  end

  @impl true
  def handle_info({:update_weather, _weather}, state) do
    Logger.debug("Dashboard received new weather data")
    update_dashboard(state)
    {:noreply, state}
  end

  # helper functions

  defp schedule_next_minute(message) do
    now = System.system_time(:millisecond)
    next_minute = div(now, 60_000) * 60_000 + 60_000
    remaining_time = next_minute - now
    :timer.send_after(remaining_time, __MODULE__, message)
  end

  defp get_time_string do
    DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%H:%M")
  end

  defp update_dashboard(state) do
    time_string = get_time_string()
    bitmap = Bitmap.new(Display.width(), Display.height())

    # render temperature
    temperature = Weather.get_temperature()
    bitmap = if temperature do
      temp_string = :erlang.float_to_binary(temperature / 1, decimals: 1) <> "°C"
      place_text(bitmap, state.font, temp_string, :top, :left)
    else
      bitmap
    end

    # render rain
    # {rainfall_rate, rainfall_intensity} = Weather.get_rain()

    # bitmap =
    #   place_text(bitmap, state.font, "R #{rainfall_rate}  I #{rainfall_intensity}",
    #     align_vertically: :top,
    #     align_horizontally: :left
    #   )

    # render wind
    bitmap =
      try do
        wind_speed  = Weather.get_wind_speed()
        place_text(bitmap, state.font, :erlang.float_to_binary(wind_speed / 1, decimals: 1) <> " " <> <<@ms_symbol::utf8>>, :bottom, :left)
      rescue
        _ -> bitmap  # Return unchanged bitmap if wind data is unavailable
      end

    bitmap =
      try do
        weather_bitmap = Weather.bitmap_48(Display.height())
        |> Bitmap.crop_relative(Display.width(), Display.height(), rel_x: :center, rel_y: :middle)

        Bitmap.overlay(bitmap, weather_bitmap)
      rescue
        _ -> bitmap  # Return unchanged bitmap if weather bitmap creation fails
      end

    # plot temperature hours

    # render time

    bitmap = place_text(bitmap, state.font, <<@clock_symbol::utf8>>, :top, :right)
    bitmap = place_text(bitmap, state.font, time_string, :bottom, :right)

    if bitmap != state.bitmap do
      Display.set(bitmap)
    end
  end

  defp place_text(bitmap, font, text, align_vertically, align_horizontally) do
    Renderer.place_text(bitmap, font, text,
      align: align_horizontally,
      valign: align_vertically
    )
  end
end
