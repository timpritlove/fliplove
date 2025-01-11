defmodule Fliplove.Weather.OpenWeather do
  @moduledoc """
  OpenWeather service implementation (formerly OpenWeatherMap).
  Requires an API key from OpenWeather to be set in the FLIPLOVE_OPENWEATHERMAP_API_KEY environment variable.
  """

  require Logger

  @behaviour Fliplove.Weather.WeatherService

  @base_url "https://api.openweathermap.org/data/3.0"
  @max_forecast_hours 120  # OpenWeather supports up to 5 days of hourly data
  @update_interval :timer.minutes(5)
  @api_key_env "FLIPLOVE_OPENWEATHERMAP_API_KEY"

  @impl true
  def get_current_weather(latitude, longitude) do
    with {:ok, api_key} <- get_api_key(),
         {:ok, data} <- call_api("/onecall", api_key, latitude, longitude) do

      current = data["current"]
      rain_last_hour = get_in(current, ["rain", "1h"]) || 0.0

      {:ok, %{
        temperature: current["temp"],
        wind_speed: current["wind_speed"],
        rainfall_rate: rain_last_hour
      }}
    end
  end

  @impl true
  def get_hourly_forecast(latitude, longitude, hours) when hours > 0 do
    with {:ok, api_key} <- get_api_key(),
         {:ok, data} <- call_api("/onecall", api_key, latitude, longitude) do

      hourly_data = data["hourly"]
      daily_data = data["daily"]

      # Extract sunrise/sunset times for determining night time
      sun_events = daily_data
      |> Enum.flat_map(fn day ->
        [
          DateTime.from_unix!(day["sunrise"]),
          DateTime.from_unix!(day["sunset"])
        ]
      end)
      |> Enum.sort_by(&DateTime.to_unix/1)

      # Take only the requested number of hours, up to the maximum supported
      hours = min(hours, @max_forecast_hours)
      hourly = hourly_data
      |> Enum.take(hours)
      |> Enum.map(fn hour ->
        datetime = DateTime.from_unix!(hour["dt"])
        rain_rate = get_in(hour, ["rain", "1h"]) || 0.0

        %{
          datetime: datetime,
          temperature: hour["temp"],
          rainfall_rate: rain_rate,
          is_night: is_night?(datetime, sun_events)
        }
      end)

      {:ok, hourly}
    end
  end

  @impl true
  def get_update_interval, do: @update_interval

  # Private helper functions

  defp get_api_key do
    case System.get_env(@api_key_env) do
      nil ->
        Logger.error("OpenWeather API key not found in environment variable #{@api_key_env}")
        {:error, :missing_api_key}
      key -> {:ok, key}
    end
  end

  defp call_api(endpoint, api_key, latitude, longitude) do
    url = @base_url <> endpoint

    params = [
      {"lat", latitude},
      {"lon", longitude},
      {"units", "metric"},
      {"appid", api_key}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, reason} ->
            Logger.error("Failed to parse OpenWeather response: #{inspect(reason)}")
            {:error, :invalid_response}
        end

      {:ok, %{status_code: 401}} ->
        Logger.error("OpenWeather API key is invalid")
        {:error, :invalid_api_key}

      {:ok, %{status_code: status_code}} ->
        Logger.error("OpenWeather API returned #{status_code}")
        {:error, :api_error}

      {:error, reason} ->
        Logger.error("OpenWeather API call failed: #{inspect(reason)}")
        {:error, :network_error}
    end
  end

  defp is_night?(datetime, sun_events) do
    unix_time = DateTime.to_unix(datetime)

    # Find the surrounding sun events (alternating sunrise/sunset)
    {prev_event, next_event} = sun_events
    |> Enum.split_with(&(DateTime.to_unix(&1) <= unix_time))
    |> then(fn {prev, next} -> {List.last(prev), List.first(next)} end)

    case {prev_event, next_event} do
      {nil, nil} -> true  # No sun events available
      {prev, _next} ->
        # If we're between events, check if the previous event was a sunset
        # This works because sun events alternate between sunrise and sunset
        prev_index = Enum.find_index(sun_events, &(&1 == prev))
        prev_index != nil and rem(prev_index, 2) == 1
    end
  end
end
