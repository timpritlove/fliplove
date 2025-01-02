defmodule Fliplove.Apps.Dashboard do
  alias Fliplove.Bitmap
  alias Fliplove.Display
  alias Fliplove.Font.Renderer

  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use Fliplove.Apps.Base
  alias Phoenix.PubSub
  alias Fliplove.{Weather}
  alias Fliplove.Font.{Library}
  require Logger
  # import Fliplove.PrettyDump

  defstruct font: nil, bitmap: nil, weather_available: false

  @font "flipdot"
  # @clock_symbol 0xF017
  # @ms_symbol 0xF018
  # @nbs_symbol 160
  # @wind_symbol 0xF72E

  def init_app(_opts) do
    # Check if weather service is available
    weather_available =
      try do
        Weather.get_weather()
        true
      rescue
        _ -> false
      end

    if not weather_available do
      Logger.warning("Weather service not available, dashboard will run with limited functionality")
    end

    state = %__MODULE__{
      font: Library.get_font_by_name(@font),
      bitmap: nil,
      weather_available: weather_available
    }

    update_dashboard(state)

    schedule_next_minute(:clock_timer)

    if weather_available do
      PubSub.subscribe(Fliplove.PubSub, Weather.topic())
    end

    {:ok, state}
  end

  # server functions

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
      # Fallback to UTC if timezone is empty
      "" -> "Etc/UTC"
      # Keep original timezone abbreviation
      tz -> tz
    end
  end

  defp get_max_min_temps do
    case Weather.get_48_hour_temperature() do
      [] ->
        {nil, nil}

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
    Bitmap.new(Display.width(), Display.height())
    |> render_current_temperature(state)
    |> render_time(state.font)
    |> render_temperature_chart(state)
    |> render_temperature_extremes(state)
    |> maybe_update_display(state.bitmap)
  end

  defp render_current_temperature(bitmap, %{weather_available: false, font: font}) do
    place_text(bitmap, font, "No weather", :top, :left)
  end

  defp render_current_temperature(bitmap, %{weather_available: true, font: font}) do
    case Weather.get_current_temperature() do
      nil -> bitmap
      temp -> place_text(bitmap, font, format_temp(temp), :top, :left)
    end
  end

  defp render_time(bitmap, font) do
    case safe_get_time_string() do
      {:ok, time_string} -> place_text(bitmap, font, time_string, :bottom, :left)
      {:error, _} -> bitmap
    end
  end

  defp render_temperature_chart(bitmap, %{weather_available: false}) do
    bitmap
  end

  defp render_temperature_chart(bitmap, %{weather_available: true}) do
    render_temperature_chart(bitmap)
  end

  defp render_temperature_extremes(bitmap, %{weather_available: false, font: font}) do
    place_text(bitmap, font, "---", :top, :right)
  end

  defp render_temperature_extremes(bitmap, font) do
    {max_temp, min_temp} = get_max_min_temps()

    bitmap
    |> place_text(font, format_temp(max_temp), :top, :right)
    |> place_text(font, format_temp(min_temp), :bottom, :right)
  end

  defp safe_get_time_string do
    {:ok, get_time_string()}
  rescue
    error -> {:error, error}
  end

  defp render_temperature_chart(bitmap) do
    case safe_create_temperature_chart() do
      {:ok, weather_bitmap} -> Bitmap.overlay(bitmap, weather_bitmap)
      {:error, _} -> bitmap
    end
  end

  defp safe_create_temperature_chart do
    weather_bitmap =
      create_48_hour_temperature_chart(Display.height())
      |> Bitmap.crop_relative(Display.width(), Display.height(), rel_x: :center, rel_y: :middle)

    {:ok, weather_bitmap}
  rescue
    error -> {:error, error}
  end

  defp maybe_update_display(new_bitmap, current_bitmap) do
    if new_bitmap != current_bitmap do
      Display.set(new_bitmap)
    end

    new_bitmap
  end

  # Temperature chart creation functions
  defp create_48_hour_temperature_chart(height) do
    chart_dimensions = %{
      # Reduce height by 2 for frame
      height: height - 2,
      width: 48,
      total_height: height
    }

    Weather.get_48_hour_temperature()
    |> convert_to_local_times()
    |> scale_temperatures(chart_dimensions.height)
    |> create_temperature_bitmap(chart_dimensions)
    |> add_midnight_markers(chart_dimensions)
    |> add_frame()
  end

  defp convert_to_local_times(temperatures) do
    timezone = get_system_timezone()

    Enum.map(temperatures, fn {temperature, datetime, index} ->
      local_datetime = DateTime.shift_zone!(datetime, timezone, Tz.TimeZoneDatabase)
      hour = local_datetime |> Map.get(:hour)
      {temperature, hour, index}
    end)
  end

  defp scale_temperatures(temp_data, chart_height) do
    temps = Enum.map(temp_data, fn {t, _, _} -> t end)
    min_temp = Enum.min(temps)
    max_temp = Enum.max(temps)
    range = max_temp - min_temp

    Enum.map(temp_data, fn {temperature, hour, index} ->
      temp_y = trunc((temperature - min_temp) * (chart_height - 1) / range)
      {temperature, temp_y, hour, index}
    end)
  end

  defp create_temperature_bitmap(scaled_temps, dimensions) do
    temp_matrix =
      for {{_temp, temp_y, _hour, x}, _index} <- Enum.with_index(scaled_temps),
          into: %{} do
        # Offset by 1 for frame
        {{x + 1, temp_y + 1}, 1}
      end

    {Bitmap.new(dimensions.width + 2, dimensions.total_height, temp_matrix), scaled_temps}
  end

  defp add_midnight_markers({bitmap, scaled_temps}, dimensions) do
    # Add midnight markers (2 dots from top and bottom)
    midnight_matrix = create_time_markers(scaled_temps, bitmap, dimensions, 0, 2)

    # Add noon markers (1 dot from bottom)
    noon_matrix = create_time_markers(scaled_temps, bitmap, dimensions, 12, 1)

    # Combine both matrices
    combined_matrix = Map.merge(midnight_matrix, noon_matrix)
    marker_bitmap = Bitmap.new(dimensions.width + 2, dimensions.total_height, combined_matrix)
    Bitmap.overlay(bitmap, marker_bitmap)
  end

  defp create_time_markers(scaled_temps, bitmap, dimensions, hour, dot_count) do
    for {{_temp, _temp_y, temp_hour, x}, _index} <- Enum.with_index(scaled_temps),
        temp_hour == hour,
        y <- get_marker_positions(dimensions.height, dot_count),
        not has_neighbor_temp?(bitmap.matrix, x + 1, y),
        into: %{} do
      {{x + 1, y}, 1}
    end
  end

  defp get_marker_positions(chart_height, dot_count) do
    Enum.to_list(1..dot_count) ++ Enum.to_list((chart_height - (dot_count - 1))..chart_height)
  end

  defp add_frame(bitmap) do
    frame_bitmap = Bitmap.frame(bitmap.width, bitmap.height)
    Bitmap.overlay(frame_bitmap, bitmap)
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
