defmodule Fliplove.Weather.OpenWeather do
  @moduledoc """
  OpenWeather service implementation (formerly OpenWeatherMap).
  Requires an API key from OpenWeather to be set in the FLIPLOVE_OPENWEATHERMAP_API_KEY environment variable.

  ## Day/Night Determination
  OpenWeather provides day/night information in two ways:
  1. Through sunrise/sunset times in the daily data
  2. Through the weather icon codes in hourly data, where icons end with:
     - 'd' for day (e.g. "01d", "02d", "03d")
     - 'n' for night (e.g. "01n", "02n", "03n")

  We use method #2 (icon codes) as it's OpenWeather's own determination of day/night
  for each specific hour, which should account for edge cases and local variations.
  Note that OpenWeather's determination might differ from other services due to
  different criteria for what constitutes day/night (e.g. civil twilight vs sunrise).
  """

  require Logger

  @behaviour Fliplove.Weather.WeatherService

  @base_url "https://api.openweathermap.org/data/3.0"
  # OpenWeather supports up to 5 days of hourly data
  @max_forecast_hours 120
  @update_interval :timer.minutes(5)
  @api_key_env "FLIPLOVE_OPENWEATHERMAP_API_KEY"

  @impl Fliplove.Weather.WeatherService
  def get_current_weather(latitude, longitude) do
    with {:ok, api_key} <- get_api_key(),
         {:ok, data} <- call_api("/onecall", api_key, latitude, longitude) do
      current = data["current"]
      rain_last_hour = get_in(current, ["rain", "1h"]) || 0.0

      {:ok,
       %{
         temperature: current["temp"],
         wind_speed: current["wind_speed"],
         rainfall_rate: rain_last_hour
       }}
    end
  end

  @impl Fliplove.Weather.WeatherService
  def get_hourly_forecast(latitude, longitude, hours) when hours > 0 do
    with {:ok, api_key} <- get_api_key(),
         {:ok, data} <- call_api("/onecall", api_key, latitude, longitude) do
      hourly_data = data["hourly"]

      # Take only the requested number of hours, up to the maximum supported
      hours = min(hours, @max_forecast_hours)

      hourly =
        hourly_data
        |> Enum.take(hours)
        |> Enum.map(fn hour ->
          hour_utc = DateTime.from_unix!(hour["dt"])

          # OpenWeather provides day/night information in the weather icon code
          # The icon code ends with:
          # - 'd' for day (e.g. "01d", "02d", "03d", etc.)
          # - 'n' for night (e.g. "01n", "02n", "03n", etc.)
          [weather | _] = hour["weather"]
          icon = weather["icon"]

          is_night =
            cond do
              # 'd' indicates day
              String.ends_with?(icon, "d") ->
                false

              # 'n' indicates night
              String.ends_with?(icon, "n") ->
                true

              # default case
              true ->
                Logger.warning("Unexpected OpenWeather icon format: #{icon}")
                # Default to night if format is unexpected
                true
            end

          %{
            datetime: hour_utc,
            temperature: hour["temp"],
            rainfall_rate: get_in(hour, ["rain", "1h"]) || 0.0,
            is_night: is_night
          }
        end)

      {:ok, hourly}
    end
  end

  @impl Fliplove.Weather.WeatherService
  def get_update_interval, do: @update_interval

  # Private helper functions

  defp get_api_key do
    case System.get_env(@api_key_env) do
      nil ->
        Logger.error("OpenWeather API key not found in environment variable #{@api_key_env}")
        {:error, :missing_api_key}

      key ->
        {:ok, key}
    end
  end

  defp call_api(endpoint, api_key, latitude, longitude) do
    url = @base_url <> endpoint

    params = [
      {"lat", latitude},
      {"lon", longitude},
      {"units", "metric"},
      {"appid", api_key},
      # Get times in the local timezone of the coordinates
      {"timezone", "auto"}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

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
end
