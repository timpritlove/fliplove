defmodule Flipdot.App.Dashboard do
  alias Flipdot.Bitmap
  alias Flipdot.Display
  alias Flipdot.Font.Renderer

  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use GenServer
  alias Phoenix.PubSub
  alias Flipdot.{Weather}
  alias Flipdot.Font.{Library}
  require Logger
  # import Flipdot.PrettyDump

  defstruct font: nil, bitmap: nil

  @registry Flipdot.App.Registry

  @font "flipdot"
  #@clock_symbol 0xF017
  #@ms_symbol 0xF018
  #@nbs_symbol 160
  #@wind_symbol 0xF72E

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
    timezone = get_system_timezone()
    DateTime.now!(timezone, Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%H:%M")
  end

  defp get_system_timezone do
    {tz_string, 0} = System.cmd("date", ["+%Z"])

    case String.trim(tz_string) do
      "" -> "Etc/UTC"  # Fallback to UTC if timezone is empty
      tz -> tz  # Keep original timezone abbreviation
    end
  end

  defp get_max_min_temps do
    case Weather.get_48_hour_temperature() do
      [] -> {nil, nil}
      temperatures ->
        temps = Enum.map(temperatures, fn {t, _, _} -> t end)
        {Enum.max(temps), Enum.min(temps)}
    end
  end

  defp format_temp(nil), do: "N/A"
  defp format_temp(temp) do
    :erlang.float_to_binary(temp / 1, decimals: 1) <> "°C"
  end

  defp update_dashboard(state) do
    bitmap = Bitmap.new(Display.width(), Display.height())

    # render temperature
    temperature = Weather.get_current_temperature()
    bitmap = if temperature do
      place_text(bitmap, state.font, format_temp(temperature), :top, :left)
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
        time_string = get_time_string()
        place_text(bitmap, state.font, time_string, :bottom, :left)
      rescue
        _ -> bitmap  # Return unchanged bitmap if time formatting fails
      end

    bitmap =
      try do
        weather_bitmap = create_48_hour_temperature_chart(Display.height())
        |> Bitmap.crop_relative(Display.width(), Display.height(), rel_x: :center, rel_y: :middle)

        Bitmap.overlay(bitmap, weather_bitmap)
      rescue
        _ -> bitmap  # Return unchanged bitmap if weather bitmap creation fails
      end

    # render max/min temperatures
    {max_temp, min_temp} = get_max_min_temps()
    bitmap = place_text(bitmap, state.font, format_temp(max_temp), :top, :right)
    bitmap = place_text(bitmap, state.font, format_temp(min_temp), :bottom, :right)

    if bitmap != state.bitmap do
      Display.set(bitmap)
    end
  end

  # Temperature chart creation functions
  defp create_48_hour_temperature_chart(height) do
    temperatures = Weather.get_48_hour_temperature()
    timezone = get_system_timezone()
    chart_height = height - 2  # Reduce height by 2 for frame
    chart_width = 48

    # Convert temperatures to local time and extract hours
    scaled_temps =
      for {temperature, datetime, index} <- temperatures do
        local_datetime = DateTime.shift_zone!(datetime, timezone, Tz.TimeZoneDatabase)
        hour = local_datetime |> Map.get(:hour)
        {temperature, hour, index}
      end

    temps = Enum.map(scaled_temps, fn {t, _, _} -> t end)
    min_temp = Enum.min(temps)
    max_temp = Enum.max(temps)
    range = max_temp - min_temp

    scaled_temps = Enum.map(scaled_temps, fn {temperature, hour, index} ->
      temp_y = trunc((temperature - min_temp) * (chart_height - 1) / range)
      {temperature, temp_y, hour, index}
    end)

    temp_matrix =
      for {{_temp, temp_y, _hour, x}, _index} <- Enum.with_index(scaled_temps),
          into: %{} do
        {{x + 1, temp_y + 1}, 1}  # Offset by 1 for frame
      end

    temp_bitmap = Bitmap.new(chart_width + 2, height, temp_matrix)

    midnight_matrix =
      for {{_temp, _temp_y, hour, x}, _index} <- Enum.with_index(scaled_temps),
          hour == 0,
          y <- Enum.to_list(1..2) ++ Enum.to_list((chart_height - 1)..chart_height),
          not has_neighbor_temp?(temp_matrix, x + 1, y),
          into: %{} do
        {{x + 1, y}, 1}
      end

    midnight_bitmap = Bitmap.new(chart_width + 2, height, midnight_matrix)

    frame_bitmap = Bitmap.frame(chart_width + 2, height)

    frame_bitmap
    |> Bitmap.overlay(midnight_bitmap)
    |> Bitmap.overlay(temp_bitmap)
  end

  # Helper to check if any neighboring position has a temperature pixel
  defp has_neighbor_temp?(temp_matrix, x, y) do
    Enum.any?(-1..1, fn dx ->
      Enum.any?(-1..1, fn dy ->
        Map.get(temp_matrix, {x + dx, y + dy}, 0) == 1
      end)
    end)
  end

  defp place_text(bitmap, font, text, align_vertically, align_horizontally) do
    Renderer.place_text(bitmap, font, text,
      align: align_horizontally,
      valign: align_vertically
    )
  end
end
