defmodule Fliplove.Weather.OpenMeteo do
  @moduledoc """
  OpenMeteo weather service implementation.
  Uses the free OpenMeteo API which doesn't require an API key.
  """

  require Logger

  @behaviour Fliplove.Weather.WeatherService

  @base_url "https://api.open-meteo.com/v1"
  @max_forecast_hours 168  # OpenMeteo supports up to 7 days of hourly data
  @update_interval :timer.minutes(5)

  @impl true
  def get_current_weather(latitude, longitude) do
    url = "#{@base_url}/forecast"

    params = [
      {"latitude", latitude},
      {"longitude", longitude},
      {"current_weather", true},
      {"timezone", "auto"}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            current = data["current_weather"]
            {:ok, %{
              temperature: current["temperature"],
              wind_speed: current["windspeed"],
              rainfall_rate: 0.0  # OpenMeteo doesn't provide current rainfall in free tier
            }}

          {:error, reason} ->
            Logger.error("Failed to parse OpenMeteo response: #{inspect(reason)}")
            {:error, :invalid_response}
        end

      {:ok, %{status_code: status_code}} ->
        Logger.error("OpenMeteo API returned #{status_code}")
        {:error, :api_error}

      {:error, reason} ->
        Logger.error("OpenMeteo API call failed: #{inspect(reason)}")
        {:error, :network_error}
    end
  end

  @impl true
  def get_hourly_forecast(latitude, longitude, hours) when hours > 0 do
    url = "#{@base_url}/forecast"
    hours = min(hours, @max_forecast_hours)

    params = [
      {"latitude", latitude},
      {"longitude", longitude},
      {"hourly", "temperature_2m,precipitation"},
      {"daily", "sunrise,sunset"},
      {"timezone", "GMT"},
      {"forecast_hours", hours}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            hourly_data = data["hourly"]
            daily_data = data["daily"]
            timezone = data["timezone"]

            hourly = Enum.zip_with([
              hourly_data["time"],
              hourly_data["temperature_2m"],
              hourly_data["precipitation"]
            ], fn [time, temp, precip] ->
              datetime = parse_time(time, timezone)
              is_night = is_night?(datetime, daily_data["sunrise"], daily_data["sunset"], timezone)

              %{
                datetime: datetime,
                temperature: temp,
                rainfall_rate: precip,
                is_night: is_night
              }
            end)

            {:ok, hourly}

          {:error, reason} ->
            Logger.error("Failed to parse OpenMeteo response: #{inspect(reason)}")
            {:error, :invalid_response}
        end

      {:ok, %{status_code: status_code}} ->
        Logger.error("OpenMeteo API returned #{status_code}")
        {:error, :api_error}

      {:error, reason} ->
        Logger.error("OpenMeteo API call failed: #{inspect(reason)}")
        {:error, :network_error}
    end
  end

  @impl true
  def get_update_interval, do: @update_interval

  # Private helper functions

  defp parse_time(time, timezone) do
    # OpenMeteo returns times in UTC when timezone=GMT
    naive = NaiveDateTime.from_iso8601!(time <> ":00")
    utc = DateTime.from_naive!(naive, "Etc/UTC")
    DateTime.shift_zone!(utc, timezone)
  end

  defp is_night?(datetime, sunrises, sunsets, timezone) do
    unix_time = DateTime.to_unix(datetime)

    # Find the surrounding sun events
    prev_sunrise = Enum.find(sunrises || [], fn time ->
      sunrise = parse_time(time, timezone)
      DateTime.to_unix(sunrise) <= unix_time
    end)
    prev_sunset = Enum.find(sunsets || [], fn time ->
      sunset = parse_time(time, timezone)
      DateTime.to_unix(sunset) <= unix_time
    end)
    next_sunrise = Enum.find(Enum.reverse(sunrises || []), fn time ->
      sunrise = parse_time(time, timezone)
      DateTime.to_unix(sunrise) > unix_time
    end)
    next_sunset = Enum.find(Enum.reverse(sunsets || []), fn time ->
      sunset = parse_time(time, timezone)
      DateTime.to_unix(sunset) > unix_time
    end)

    cond do
      # Between sunset and sunrise
      prev_sunset != nil and next_sunrise != nil -> true
      # Between sunrise and sunset
      prev_sunrise != nil and next_sunset != nil -> false
      # Before first sunrise of the day (no previous sunset)
      next_sunrise != nil and prev_sunset == nil -> true
      # After last sunset of the day (no next sunrise)
      prev_sunset != nil and next_sunrise == nil -> true
      # After sunrise but before sunset (no next sunset)
      prev_sunrise != nil and next_sunset == nil -> false
      # Default to true if we can't determine
      true -> true
    end
  end
end
