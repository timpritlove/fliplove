defmodule Fliplove.Weather do
  @moduledoc """
  Retrieve weather data on a regular basis. Uses OpenWeatherMap API which
  needs an account to access it. Pass the developer API key to the library
  via the FLIPLOVE_OPENWEATHERMAP_API_KEY environment variable.
  """
  alias Phoenix.PubSub
  use GenServer

  require HTTPoison
  require Logger

  defstruct [:timer, :service_module, :latitude, :longitude, :weather, :weather_timestamp]

  @latitude_env "FLIPLOVE_LATITUDE"
  @longitude_env "FLIPLOVE_LONGITUDE"

  @topic "weather:update"

  @openweathermap_onecall_url "https://api.openweathermap.org/data/3.0/onecall"
  @api_key_file "data/keys/openweathermap.txt"
  @api_key_env "FLIPLOVE_OPENWEATHERMAP_API_KEY"

  @ip_geolocation_url "http://ip-api.com/json"

  # Add service module constants
  @weather_service_env "FLIPLOVE_WEATHER_SERVICE"
  @default_service :open_meteo

  def topic, do: @topic

  # Client API

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def get_weather do
    GenServer.call(__MODULE__, :get_current_weather)
  end

  def update_weather do
    GenServer.call(__MODULE__, :update_weather)
  end

  def get_current_temperature do
    case get_weather() do
      nil -> nil
      weather -> weather.temperature
    end
  end

  def get_wind_speed do
    case get_weather() do
      nil -> nil
      weather -> weather.wind_speed
    end
  end

  def get_rain do
    case get_weather() do
      nil -> {0.0, 0}
      weather ->
        rainfall_rate = weather.rainfall_rate
        {rainfall_rate, rainfall_intensity(rainfall_rate)}
    end
  end

  @doc """
  Get hourly forecast for the specified number of hours.
  Returns a list of hourly weather data or an empty list if no data is available.
  The actual number of hours returned may be less than requested, depending on the service's capabilities.
  """
  def get_hourly_forecast(hours) when is_integer(hours) and hours > 0 do
    GenServer.call(__MODULE__, {:get_hourly_forecast, hours})
  end

  # initialization functions

  @impl true
  def init(state) do
    Logger.debug("Initializing Weather service...")

    with {:ok, service_module} <- get_service_module(),
         {:ok, lat, lon, source} <- get_location() do

      service_name = service_module |> Module.split() |> List.last()
      Logger.debug("Selected weather service: #{service_name}")
      Logger.debug("Location: #{lat}, #{lon} (source: #{source})")

      update_interval = service_module.get_update_interval()
      Logger.debug("Weather update interval: #{update_interval}ms")

      # Update weather information in a second and then periodically
      Logger.debug("Scheduling initial weather update...")
      {:ok, _initial_timer} = :timer.send_after(1_000, :update_weather)
      Logger.debug("Scheduling periodic weather updates...")
      {:ok, periodic_timer} = :timer.send_interval(update_interval, :update_weather)

      Logger.info("Weather service enabled: #{service_name}")
      Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

      {:ok, %{state |
        service_module: service_module,
        latitude: lat,
        longitude: lon,
        timer: periodic_timer
      }}
    else
      {:error, reason} ->
        Logger.error("Failed to initialize weather service: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.timer do
      {:ok, :cancel} = :timer.cancel(state.timer)
    end

    Logger.info("Terminating weather service")
  end

  # server functions

  @impl true
  def handle_call(:get_current_weather, _from, state) do
    {:reply, state.weather, state}
  end

  @impl true
  def handle_call(:get_weather_with_timestamp, _from, state) do
    {:reply, {state.weather, state.weather_timestamp}, state}
  end

  @impl true
  def handle_call(:update_weather, _from, state) do
    {:reply, :ok, update_weather(state)}
  end

  @impl true
  def handle_call({:get_hourly_forecast, hours}, _from, state) do
    case state.service_module.get_hourly_forecast(state.latitude, state.longitude, hours) do
      {:ok, forecast} -> {:reply, forecast, state}
      {:error, _reason} -> {:reply, [], state}
    end
  end

  @impl true
  def handle_info(:update_weather, state) do
    Logger.debug("Updating weather data...")
    state = update_weather(state)
    {:noreply, state}
  end

  defp update_weather(state) do
    Logger.debug("Fetching weather data from service...")
    case state.service_module.get_current_weather(state.latitude, state.longitude) do
      {:ok, weather} ->
        timestamp = DateTime.utc_now()
        Logger.debug("Weather data updated successfully")
        PubSub.broadcast(Fliplove.PubSub, topic(), {:update_weather, weather})
        %{state | weather: weather, weather_timestamp: timestamp}

      {:error, reason} ->
        Logger.warning("Failed to update weather: #{inspect(reason)}")
        state
    end
  end

  # Rainfall intensity calculation using pattern matching
  @rainfall_intensity_thresholds [
    {50.0, 4},
    {7.6, 3},
    {2.6, 2},
    {0.1, 1},
    {0.0, 0}
  ]

  def rainfall_intensity(rainfall_rate) when rainfall_rate >= 0 do
    rainfall_rate = rainfall_rate / 1

    {_, intensity} =
      Enum.find(@rainfall_intensity_thresholds, fn {threshold, _} ->
        rainfall_rate >= threshold
      end)

    intensity
  end

  # Wind force calculation using pattern matching
  @beaufort_scale_thresholds [
    {32.7, 12},
    {28.5, 11},
    {24.5, 10},
    {20.8, 9},
    {17.2, 8},
    {13.9, 7},
    {10.8, 6},
    {8.0, 5},
    {5.5, 4},
    {3.4, 3},
    {1.6, 2},
    {0.3, 1},
    {0.0, 0}
  ]

  def wind_force(wind_speed) when wind_speed >= 0 do
    wind_speed = wind_speed / 1

    {_, force} =
      Enum.find(@beaufort_scale_thresholds, fn {threshold, _} ->
        wind_speed >= threshold
      end)

    force
  end

  # retrieve OWM API key from either a local config file or from the environment

  def get_api_key do
    case File.read(@api_key_file) do
      {:ok, key} ->
        {:ok, String.trim(key)}

      {:error, _} ->
        case System.get_env(@api_key_env) do
          nil -> {:error, "No API key found in file or environment"}
          key -> {:ok, key}
        end
    end
  end

  def call_openweathermap(api_key, latitude, longitude) do
    url = @openweathermap_onecall_url

    params = [
      {"lat", latitude},
      {"lon", longitude},
      {"units", "metric"},
      {"appid", api_key}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %{status_code: status_code}} ->
        Logger.warning("OpenWeatherMap API call failed (#{status_code})")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warning("OpenWeatherMap API call failed: #{inspect(reason)}")
        nil
    end
  end

  defp get_location do
    case {System.get_env(@latitude_env), System.get_env(@longitude_env)} do
      {lat, lon} when is_binary(lat) and is_binary(lon) ->
        {:ok, String.to_float(lat), String.to_float(lon), "environment variables"}

      _ ->
        Logger.info("No location coordinates in environment, falling back to IP geolocation")
        get_location_from_ip()
    end
  end

  defp get_location_from_ip do
    case HTTPoison.get(@ip_geolocation_url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode!(body) do
          %{"lat" => lat, "lon" => lon} ->
            {:ok, lat, lon, "IP geolocation"}

          _ ->
            {:error, "Invalid response from IP geolocation service"}
        end

      {:error, reason} ->
        {:error, "Failed to get location from IP: #{inspect(reason)}"}
    end
  end

  def get_weather_with_timestamp(), do: GenServer.call(__MODULE__, :get_weather_with_timestamp)

  def get_48_hour_temperature() do
    with {:ok, weather} <- get_weather_data(),
         {:ok, hourly} <- get_hourly_data(weather),
         {:ok, daily} <- get_daily_data(weather) do
      parse_hourly_temperatures(hourly, daily)
    else
      _ -> []
    end
  end

  defp get_weather_data do
    case get_weather() do
      nil -> {:error, :no_weather_data}
      weather when is_map(weather) -> {:ok, weather}
    end
  end

  defp get_hourly_data(weather) do
    case weather["hourly"] do
      nil -> {:error, :no_hourly_data}
      hourly when is_list(hourly) -> {:ok, hourly}
      _ -> {:error, :invalid_hourly_data}
    end
  end

  defp get_daily_data(weather) do
    case weather["daily"] do
      nil -> {:error, :no_daily_data}
      daily when is_list(daily) -> {:ok, daily}
      _ -> {:error, :invalid_daily_data}
    end
  end

  defp parse_hourly_temperatures(hourly, daily) do
    # Convert sunrise/sunset times to UTC timestamps
    sun_events = daily
    |> Enum.flat_map(fn day ->
      # Each day gives us a sunrise and sunset point
      [
        {:sunrise, DateTime.from_unix!(day["sunrise"])},
        {:sunset, DateTime.from_unix!(day["sunset"])}
      ]
    end)
    |> Enum.sort_by(fn {_, time} -> DateTime.to_unix(time) end)

    Logger.debug("Sun events in chronological order:")
    Enum.each(sun_events, fn {event, time} ->
      Logger.debug("  #{event}: #{time}")
    end)

    for {hourly_data, index} <- Enum.with_index(hourly),
        temperature = hourly_data["temp"] / 1,
        datetime = DateTime.from_unix!(hourly_data["dt"]) do

      # Find the surrounding sun events
      {prev_event, next_event} = get_surrounding_events(datetime, sun_events)

      # Determine if it's night based on the surrounding events
      is_night = case {prev_event, next_event} do
        {nil, nil} ->
          Logger.warning("No sun events found around #{datetime}")
          true
        {{:sunset, _}, {:sunrise, _}} -> true  # Between sunset and sunrise
        {{:sunrise, _}, {:sunset, _}} -> false # Between sunrise and sunset
        {nil, {:sunrise, _}} -> true          # Before first sunrise
        {nil, {:sunset, _}} -> false          # Before first sunset
        {{:sunset, _}, nil} -> true           # After last sunset
        {{:sunrise, _}, nil} -> false         # After last sunrise
      end

      Logger.debug("Hour check: datetime=#{datetime}, prev_event=#{inspect(prev_event)}, next_event=#{inspect(next_event)}, is_night=#{is_night}")

      %{
        temperature: temperature,
        datetime: datetime,
        index: index,
        is_night: is_night
      }
    end
  end

  # Find the sun events immediately before and after the given datetime
  defp get_surrounding_events(datetime, sun_events) do
    unix_time = DateTime.to_unix(datetime)

    prev_event = sun_events
    |> Enum.take_while(fn {_, time} -> DateTime.to_unix(time) <= unix_time end)
    |> List.last()

    next_event = sun_events
    |> Enum.drop_while(fn {_, time} -> DateTime.to_unix(time) <= unix_time end)
    |> List.first()

    {prev_event, next_event}
  end

  # Add before get_location function
  defp get_service_module do
    service = case System.get_env(@weather_service_env) do
      "openweather" -> :open_weather
      "openmeteo" -> :open_meteo
      nil -> Application.get_env(:fliplove, :weather, []) |> Keyword.get(:service, @default_service)
      other ->
        Logger.warning("Unknown weather service in environment: #{inspect(other)}, using default")
        @default_service
    end

    case service do
      :open_meteo -> {:ok, Fliplove.Weather.OpenMeteo}
      :open_weather -> {:ok, Fliplove.Weather.OpenWeather}
      other ->
        Logger.error("Unknown weather service configured: #{inspect(other)}")
        {:error, :invalid_service}
    end
  end
end
