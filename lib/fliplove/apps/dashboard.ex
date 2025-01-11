defmodule Fliplove.Apps.Dashboard do
  alias Fliplove.Bitmap
  alias Fliplove.Display
  alias Fliplove.Font.Renderer

  @moduledoc """
  Compose a dashboard to show on flipboard
  """
  use Fliplove.Apps.Base
  alias Phoenix.PubSub
  alias Fliplove.{Weather, TimezoneHelper}
  alias Fliplove.Font.{Library}
  require Logger
  # import Fliplove.PrettyDump

  defstruct font: nil, bitmap: nil

  @font "flipdot"
  #@clock_symbol 0xF017
  #@ms_symbol 0xF018
  #@nbs_symbol 160
  #@wind_symbol 0xF72E

  def init_app(_opts) do
    offset_minutes = TimezoneHelper.get_utc_offset_minutes()
    Logger.info("Dashboard using UTC offset: #{offset_minutes} minutes")

    state = %__MODULE__{
      font: Library.get_font_by_name(@font),
      bitmap: nil
    }
    update_dashboard(state)

    schedule_next_minute(:clock_timer)
    PubSub.subscribe(Fliplove.PubSub, Weather.topic())

    {:ok, state}
  end

  # server functions

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Dashboard has been shut down.")
  end

  @impl true
  def handle_info(:clock_timer, state) do
    update_dashboard(state)
    schedule_next_minute(:clock_timer)

    {:noreply, state}
  end

  @impl true
  def handle_info({:update_weather, _weather}, state) do
    update_dashboard(state)
    {:noreply, state}
  end

  # helper functions

  defp schedule_next_minute(message) do
    offset_minutes = TimezoneHelper.get_utc_offset_minutes()
    now = DateTime.utc_now()
           |> DateTime.add(offset_minutes, :minute)

    # Calculate milliseconds until the next minute in local time
    {microseconds, _precision} = now.microsecond
    remaining_ms = (60 - now.second) * 1000 - div(microseconds, 1000)

    :timer.send_after(remaining_ms, __MODULE__, message)
  end

  defp get_time_string do
    offset_minutes = TimezoneHelper.get_utc_offset_minutes()
    # Get UTC time and add the offset
    DateTime.utc_now()
    |> DateTime.add(offset_minutes, :minute)
    |> Calendar.strftime("%H:%M")
  end

  defp get_max_min_temps do
    case get_hourly_forecast() do
      [] -> {nil, nil}
      temperatures ->
        temps = Enum.map(temperatures, & &1.temperature)
        {Enum.max(temps), Enum.min(temps)}
    end
  end

  defp format_temp(nil), do: "N/A"
  defp format_temp(temp) do
    temp = if temp == 0.0 or temp == -0.0, do: 0.0, else: temp
    :erlang.float_to_binary(temp / 1, decimals: 1) <> "°"
  end

  defp update_dashboard(state) do
    Bitmap.new(Display.width(), Display.height())
    |> render_current_temperature(state.font)
    |> render_time(state.font)
    |> render_temperature_chart()
    |> render_temperature_extremes(state.font)
    |> maybe_update_display(state.bitmap)
  end

  defp render_current_temperature(bitmap, font) do
    case Weather.get_current_temperature() do
      nil -> bitmap
      temp -> place_text(bitmap, font, format_temp(temp), :top, :left)
    end
  end

  defp render_time(bitmap, font) do
    place_text(bitmap, font, get_time_string(), :bottom, :left)
  end

  defp render_temperature_chart(bitmap) do
    weather_bitmap = create_temperature_chart(Display.height())
    result = Bitmap.crop_relative(weather_bitmap, Display.width(), Display.height(), rel_x: :center, rel_y: :middle)
    Bitmap.overlay(bitmap, result)
  end

  defp render_temperature_extremes(bitmap, font) do
    {max_temp, min_temp} = get_max_min_temps()
    bitmap
    |> place_text(font, format_temp(max_temp), :top, :right)
    |> place_text(font, format_temp(min_temp), :bottom, :right)
  end

  defp maybe_update_display(new_bitmap, current_bitmap) do
    if new_bitmap != current_bitmap do
      Display.set(new_bitmap)
    end
    new_bitmap
  end

  # Temperature chart creation functions
  defp create_temperature_chart(height) do
    forecast = get_hourly_forecast()
    width = length(forecast)
    chart_height = height - 2  # Reduce height by 2 for frame

    forecast
    |> convert_to_local_times()
    |> scale_temperatures(chart_height)
    |> create_temperature_bitmap(width + 2, height)
    |> add_midnight_markers(chart_height)
    |> add_frame()
  end

  defp convert_to_local_times(temperatures) do
    offset_minutes = TimezoneHelper.get_utc_offset_minutes()

    temperatures
    |> Enum.with_index()
    |> Enum.map(fn {temp, index} ->
      local_datetime = DateTime.add(temp.datetime, offset_minutes, :minute)
      local_hour = local_datetime.hour

      %{
        temperature: temp.temperature,
        hour: local_hour,
        index: index,
        is_night: temp.is_night
      }
    end)
  end

  defp scale_temperatures(temp_data, chart_height) do
    temps = Enum.map(temp_data, & &1.temperature)
    min_temp = Enum.min(temps)
    max_temp = Enum.max(temps)
    range = max_temp - min_temp

    Enum.map(temp_data, fn temp ->
      temp_y = trunc((temp.temperature - min_temp) * (chart_height - 1) / range)
      Map.put(temp, :y, temp_y)
    end)
  end

  defp create_temperature_bitmap(scaled_temps, width, height) do
    temp_matrix =
      for temp <- scaled_temps,
          into: %{} do
        {{temp.index + 1, temp.y + 1}, 1}  # Offset by 1 for frame
      end
    {Bitmap.new(width, height, temp_matrix), scaled_temps}
  end

  defp add_midnight_markers({bitmap, scaled_temps}, chart_height) do
    # Add midnight markers (2 dots from top and bottom)
    midnight_matrix = create_time_markers(scaled_temps, bitmap, chart_height, 0, 2)

    # Add noon markers (1 dot from bottom)
    noon_matrix = create_time_markers(scaled_temps, bitmap, chart_height, 12, 1)

    # Combine both matrices and create bitmap with same dimensions as input
    combined_matrix = Map.merge(midnight_matrix, noon_matrix)
    marker_bitmap = Bitmap.new(bitmap.width, bitmap.height, combined_matrix)
    {Bitmap.overlay(bitmap, marker_bitmap), scaled_temps}
  end

  defp create_time_markers(scaled_temps, bitmap, chart_height, hour, dot_count) do
    for temp <- scaled_temps,
        temp.hour == hour,
        y <- get_marker_positions(chart_height, dot_count),
        not has_neighbor_temp?(bitmap.matrix, temp.index + 1, y),
        into: %{} do
      {{temp.index + 1, y}, 1}
    end
  end

  defp get_marker_positions(chart_height, dot_count) do
    top = 1..dot_count
    bottom = (chart_height - dot_count + 1)..chart_height
    Enum.to_list(top) ++ Enum.to_list(bottom)
  end

  defp add_frame({bitmap, scaled_temps}) do
    frame_matrix = for x <- 0..(bitmap.width - 1),
        y <- 0..(bitmap.height - 1),
        is_frame_pixel?(x, y, bitmap.width, bitmap.height, scaled_temps),
        into: %{} do
      {{x, y}, 1}
    end

    frame_bitmap = Bitmap.new(bitmap.width, bitmap.height, frame_matrix)
    Bitmap.overlay(bitmap, frame_bitmap)
  end

  defp is_frame_pixel?(x, y, width, height, temps) do
    cond do
      # Left and right borders
      x == 0 or x == width - 1 -> true
      # Top and bottom borders with special markers
      y == 0 or y == height - 1 ->
        case Enum.find(temps, fn t -> t.index + 1 == x end) do
          %{is_night: true} -> true
          %{hour: hour} when hour in [0, 12] -> true
          _ -> false
        end
      true -> false
    end
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

  # Add helper to get hourly forecast with maximum available hours
  defp get_hourly_forecast do
    case Weather.get_hourly_forecast(54) do
      [] ->
        Logger.warning("No hourly forecast data available")
        []
      forecast -> forecast
    end
  end
end
