defmodule Fliplove.Weather.WeatherService do
  @moduledoc """
  Behaviour that all weather service implementations must follow.
  This ensures a consistent interface across different weather data providers.
  """

  @doc """
  Get the current weather conditions for the given location.
  Returns `{:ok, weather_data}` on success, or `{:error, reason}` on failure.
  """
  @callback get_current_weather(latitude :: float(), longitude :: float()) ::
              {:ok,
               %{
                 temperature: float(),
                 wind_speed: float(),
                 rainfall_rate: float()
               }}
              | {:error, term()}

  @doc """
  Get hourly forecast for the specified number of hours.
  Returns `{:ok, [forecast_data]}` on success, or `{:error, reason}` on failure.
  The actual number of hours returned may be less than requested, depending on the service's capabilities.
  """
  @callback get_hourly_forecast(latitude :: float(), longitude :: float(), hours :: pos_integer()) ::
              {:ok,
               [
                 %{
                   datetime: DateTime.t(),
                   temperature: float(),
                   rainfall_rate: float(),
                   is_night: boolean()
                 }
               ]}
              | {:error, term()}

  @doc """
  Get the update interval for this weather service in milliseconds.
  This determines how often the weather data should be refreshed.
  """
  @callback get_update_interval() :: pos_integer()
end
