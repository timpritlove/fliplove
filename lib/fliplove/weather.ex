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

  defstruct [:timer, :api_key, :latitude, :longitude, :weather, :weather_timestamp]

  @latitude_env "FLIPLOVE_LATITUDE"
  @longitude_env "FLIPLOVE_LONGITUDE"

  @topic "weather:update"

  @openweathermap_onecall_url "https://api.openweathermap.org/data/3.0/onecall"
  @api_key_file "data/keys/openweathermap.txt"
  @api_key_env "FLIPLOVE_OPENWEATHERMAP_API_KEY"

  @ip_geolocation_url "http://ip-api.com/json"

  def topic, do: @topic

  # initialization functions

  def start_link(_state) do
    Logger.debug("Starting Weather service...")

    case get_api_key() do
      {:ok, _api_key} ->
        Logger.debug("Weather service API key found")
        GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)

      {:error, reason} ->
        Logger.error("Weather service disabled: #{reason}")
        :ignore
    end
  end

  @impl true
  def init(state) do
    Logger.debug("Initializing Weather service...")

    case get_api_key() do
      {:ok, api_key} ->
        Logger.debug("Weather service API key validated")
        # Get location once during initialization
        case get_location() do
          {:ok, lat, lon, source} ->
            Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

            # update weather information in a second and then every 5 minutes
            {:ok, _} = :timer.send_after(5_000, :update_weather)
            {:ok, timer} = :timer.send_interval(300_000, :update_weather)

            {:ok, %{state | api_key: api_key, latitude: lat, longitude: lon, timer: timer}}

          {:error, reason} ->
            Logger.error("Failed to get location: #{inspect(reason)}")
            {:stop, :location_not_available}
        end

      {:error, reason} ->
        Logger.error("Failed to get API key during initialization: #{inspect(reason)}")
        {:stop, :api_key_not_available}
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.timer do
      {:ok, :cancel} = :timer.cancel(state.timer)
    end

    Logger.info("Terminating weather service")
  end

  # client functions

  def update_weather(), do: GenServer.call(__MODULE__, :update_weather)

  def get_weather(), do: GenServer.call(__MODULE__, :get_weather)

  def get_current_temperature() do
    weather = get_weather()
    weather["current"]["temp"]
  end

  def get_wind_speed() do
    weather = get_weather()
    weather["current"]["wind_speed"]
  end

  def get_rain() do
    weather = get_weather()
    rainfall_rate = weather["current"]["rain"]
    rainfall_intensity = rainfall_intensity(rainfall_rate)
    {rainfall_rate, rainfall_intensity}
  end

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
    # Extract sunrise/sunset times for all days we have data for
    sun_times = Enum.map(daily, fn day ->
      sunrise = DateTime.from_unix!(day["sunrise"])
      sunset = DateTime.from_unix!(day["sunset"])
      date = DateTime.to_date(sunrise)
      {date, {sunrise, sunset}}
    end)
    |> Map.new()  # Convert to map for easier lookup by date

    for {hourly_data, index} <- Enum.with_index(hourly),
        temperature = hourly_data["temp"] / 1,
        datetime = DateTime.from_unix!(hourly_data["dt"]) do

      date = DateTime.to_date(datetime)
      # Find the relevant day's sunrise/sunset times
      {sunrise, sunset} = case Map.get(sun_times, date) do
        nil ->
          {_, times} = Enum.max_by(sun_times, fn {date, _} -> date end)
          times
        times -> times
      end

      is_night = DateTime.compare(datetime, sunset) in [:gt, :eq] or
                DateTime.compare(datetime, sunrise) == :lt

      %{
        temperature: temperature,
        datetime: datetime,
        index: index,
        is_night: is_night
      }
    end
  end

  # Move the client function up with other client functions
  def get_weather_with_timestamp(), do: GenServer.call(__MODULE__, :get_weather_with_timestamp)

  # server functions

  @impl true
  def handle_call(:get_weather, _, state) do
    {:reply, state.weather, state}
  end

  @impl true
  def handle_call(:get_weather_with_timestamp, _, state) do
    {:reply, {state.weather, state.weather_timestamp}, state}
  end

  @impl true
  def handle_call(:update_weather, _, state) do
    {:reply, :ok, update_weather(state)}
  end

  @impl true
  def handle_info(:update_weather, state) do
    state = update_weather(state)
    {:noreply, state}
  end

  defp update_weather(state) do
    case call_openweathermap(state.api_key, state.latitude, state.longitude) do
      nil ->
        # Keep existing state on error
        state

      weather ->
        timestamp = DateTime.utc_now()
        PubSub.broadcast(Fliplove.PubSub, topic(), {:update_weather, weather})
        %{state | weather: weather, weather_timestamp: timestamp}
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
end
