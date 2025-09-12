defmodule Fliplove.Weather.OpenMeteo do
  @moduledoc """
  OpenMeteo weather service implementation.
  Uses the free OpenMeteo API which doesn't require an API key.
  """

  require Logger

  @behaviour Fliplove.Weather.WeatherService

  @base_url "https://api.open-meteo.com/v1"
  # OpenMeteo supports up to 7 days of hourly data
  @max_forecast_hours 168
  @update_interval :timer.minutes(5)

  @impl Fliplove.Weather.WeatherService
  def get_current_weather(latitude, longitude) do
    url = "#{@base_url}/forecast"

    params = [
      {"latitude", latitude},
      {"longitude", longitude},
      {"current_weather", true},
      {"timezone", "auto"}
    ]

    # Add timeout options to HTTPoison request
    options = [recv_timeout: 10_000, timeout: 10_000]

    case HTTPoison.get(url, [], params: params, options: options) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            current = data["current_weather"]

            {:ok,
             %{
               temperature: current["temperature"],
               wind_speed: current["windspeed"],
               # OpenMeteo doesn't provide current rainfall in free tier
               rainfall_rate: 0.0
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

  @impl Fliplove.Weather.WeatherService
  def get_hourly_forecast(latitude, longitude, hours) when hours > 0 do
    url = "#{@base_url}/forecast"
    hours = min(hours, @max_forecast_hours)

    params = [
      {"latitude", latitude},
      {"longitude", longitude},
      {"hourly", "temperature_2m,precipitation,is_day"},
      {"timezone", "GMT"},
      {"forecast_hours", hours}
    ]

    # Add timeout options to HTTPoison request
    options = [recv_timeout: 10_000, timeout: 10_000]

    case HTTPoison.get(url, [], params: params, options: options) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            hourly_data = data["hourly"]
            timezone = data["timezone"]

            hourly =
              Enum.zip_with(
                [
                  hourly_data["time"],
                  hourly_data["temperature_2m"],
                  hourly_data["precipitation"],
                  hourly_data["is_day"]
                ],
                fn [time, temp, precip, is_day] ->
                  datetime = parse_time(time, timezone)
                  # OpenMeteo uses 1 for day, 0 for night
                  is_night = is_day == 0

                  %{
                    datetime: datetime,
                    temperature: temp,
                    rainfall_rate: precip,
                    is_night: is_night
                  }
                end
              )

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

  @impl Fliplove.Weather.WeatherService
  def get_update_interval, do: @update_interval

  # Private helper functions

  defp parse_time(time, timezone) do
    # OpenMeteo returns times in UTC when timezone=GMT
    naive = NaiveDateTime.from_iso8601!(time <> ":00")
    utc = DateTime.from_naive!(naive, "Etc/UTC")
    DateTime.shift_zone!(utc, timezone)
  end
end
