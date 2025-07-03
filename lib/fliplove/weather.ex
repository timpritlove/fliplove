defmodule Fliplove.Weather do
  @moduledoc """
  Retrieve weather data on a regular basis. Uses a configurable weather service
  which can be set via the FLIPLOVE_WEATHER_SERVICE environment variable.
  """
  alias Phoenix.PubSub
  use GenServer

  require Logger

  alias Fliplove.Location.Nominatim

  defstruct [
    :timer,
    :service_module,
    :latitude,
    :longitude,
    :weather,
    :weather_timestamp,
    :last_error,
    :last_success,
    # Circuit breaker state
    :circuit_breaker_state,
    :failure_count,
    :last_failure_time,
    :retry_timer
  ]

  @latitude_env "FLIPLOVE_LATITUDE"
  @longitude_env "FLIPLOVE_LONGITUDE"
  @location_env "FLIPLOVE_LOCATION"

  @topic "weather:update"

  @ip_geolocation_url "http://ip-api.com/json"

  # Add service module constants
  @weather_service_env "FLIPLOVE_WEATHER_SERVICE"
  @default_service :open_meteo

  # Circuit breaker configuration
  @max_failures 3
  @circuit_breaker_timeout :timer.minutes(5)
  @retry_interval :timer.minutes(1)

  # GenServer call timeout
  @call_timeout 3_000

  def topic, do: @topic

  # Client API

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def start do
    start_link([])
  end

  def get_weather do
    try do
      GenServer.call(__MODULE__, :get_current_weather, @call_timeout)
    catch
      :exit, {:timeout, _} ->
        Logger.warning("Weather service call timed out")
        nil

      :exit, {:noproc, _} ->
        Logger.warning("Weather service not available")
        nil

      :exit, reason ->
        Logger.warning("Weather service call failed: #{inspect(reason)}")
        nil
    end
  end

  def update_weather do
    try do
      GenServer.call(__MODULE__, :update_weather, @call_timeout)
    catch
      :exit, {:timeout, _} ->
        Logger.warning("Weather service update call timed out")
        :error

      :exit, {:noproc, _} ->
        Logger.warning("Weather service not available for update")
        :error

      :exit, reason ->
        Logger.warning("Weather service update call failed: #{inspect(reason)}")
        :error
    end
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
      nil ->
        {0.0, 0}

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
    try do
      GenServer.call(__MODULE__, {:get_hourly_forecast, hours}, @call_timeout)
    catch
      :exit, {:timeout, _} ->
        Logger.warning("Weather service hourly forecast call timed out")
        []

      :exit, {:noproc, _} ->
        Logger.warning("Weather service not available for hourly forecast")
        []

      :exit, reason ->
        Logger.warning("Weather service hourly forecast call failed: #{inspect(reason)}")
        []
    end
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

      # Initialize circuit breaker state
      initial_state = %{
        state
        | service_module: service_module,
          latitude: lat,
          longitude: lon,
          circuit_breaker_state: :closed,
          failure_count: 0,
          last_failure_time: nil,
          retry_timer: nil
      }

      # Update weather information in a second and then periodically
      Logger.debug("Scheduling initial weather update...")
      {:ok, _initial_timer} = :timer.send_after(1_000, :update_weather)
      Logger.debug("Scheduling periodic weather updates...")
      {:ok, periodic_timer} = :timer.send_interval(update_interval, :update_weather)

      Logger.info("Weather service enabled: #{service_name}")
      Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

      {:ok, %{initial_state | timer: periodic_timer}}
    else
      {:error, reason} ->
        Logger.error("Failed to initialize weather service: #{inspect(reason)}")
        # Instead of stopping, start in a degraded state and retry later
        Logger.info("Starting weather service in degraded mode, will retry initialization")
        {:ok, retry_timer} = :timer.send_after(@retry_interval, :retry_initialization)

        {:ok,
         %{
           state
           | circuit_breaker_state: :open,
             failure_count: @max_failures,
             last_failure_time: DateTime.utc_now(),
             retry_timer: retry_timer
         }}
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.timer do
      {:ok, :cancel} = :timer.cancel(state.timer)
    end

    if state.retry_timer do
      {:ok, :cancel} = :timer.cancel(state.retry_timer)
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
    {:reply, :ok, do_update_weather(state)}
  end

  @impl true
  def handle_call({:get_hourly_forecast, hours}, _from, state) do
    if circuit_breaker_open?(state) do
      Logger.debug("Circuit breaker is open, not making weather service call")
      {:reply, [], state}
    else
      case state.service_module.get_hourly_forecast(state.latitude, state.longitude, hours) do
        {:ok, forecast} ->
          new_state = record_success(state)
          {:reply, forecast, new_state}

        {:error, reason} ->
          Logger.warning("Failed to get hourly forecast: #{inspect(reason)}")
          new_state = record_failure(state, reason)
          {:reply, [], new_state}
      end
    end
  rescue
    error ->
      Logger.error("Unexpected error getting hourly forecast: #{inspect(error)}")
      new_state = record_failure(state, error)
      {:reply, [], new_state}
  end

  @impl true
  def handle_info(:update_weather, state) do
    # Don't crash on update failures
    new_state = do_update_weather(state)
    {:noreply, new_state}
  rescue
    error ->
      Logger.error("Unexpected error in weather update: #{inspect(error)}")
      new_state = record_failure(state, error)
      {:noreply, new_state}
  end

  @impl true
  def handle_info(:retry_initialization, state) do
    Logger.info("Retrying weather service initialization...")

    with {:ok, service_module} <- get_service_module(),
         {:ok, lat, lon, source} <- get_location() do
      service_name = service_module |> Module.split() |> List.last()
      Logger.info("Weather service initialization successful: #{service_name}")
      Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

      update_interval = service_module.get_update_interval()
      {:ok, periodic_timer} = :timer.send_interval(update_interval, :update_weather)

      # Reset circuit breaker and update state
      new_state = %{
        state
        | service_module: service_module,
          latitude: lat,
          longitude: lon,
          timer: periodic_timer,
          circuit_breaker_state: :closed,
          failure_count: 0,
          last_failure_time: nil,
          retry_timer: nil
      }

      # Try to get initial weather data
      final_state = do_update_weather(new_state)
      {:noreply, final_state}
    else
      {:error, reason} ->
        Logger.warning("Weather service initialization still failing: #{inspect(reason)}")
        {:ok, retry_timer} = :timer.send_after(@retry_interval, :retry_initialization)
        {:noreply, %{state | retry_timer: retry_timer}}
    end
  end

  @impl true
  def handle_info(:retry_weather_service, state) do
    Logger.debug("Retrying weather service after circuit breaker timeout")

    new_state = %{state | circuit_breaker_state: :half_open, retry_timer: nil}

    final_state = do_update_weather(new_state)
    {:noreply, final_state}
  end

  defp do_update_weather(%{service_module: nil} = state) do
    Logger.debug("Weather service module not initialized, skipping update")
    state
  end

  defp do_update_weather(state) do
    if circuit_breaker_open?(state) do
      Logger.debug("Circuit breaker is open, skipping weather update")
      broadcast_weather_update(state.weather)
      state
    else
      Logger.debug("Fetching weather data from service...")

      case state.service_module.get_current_weather(state.latitude, state.longitude) do
        {:ok, weather} ->
          timestamp = DateTime.utc_now()
          Logger.debug("Weather data updated successfully")
          broadcast_weather_update(weather)
          new_state = record_success(state)
          %{new_state | weather: weather, weather_timestamp: timestamp}

        {:error, reason} ->
          Logger.warning("Failed to update weather: #{inspect(reason)}")
          # Keep existing weather data and continue running
          broadcast_weather_update(state.weather)
          record_failure(state, reason)
      end
    end
  rescue
    error ->
      Logger.error("Unexpected error updating weather: #{inspect(error)}")
      # Keep existing weather data and continue running
      broadcast_weather_update(state.weather)
      record_failure(state, error)
  end

  # Circuit breaker helper functions

  defp circuit_breaker_open?(state) do
    state.circuit_breaker_state == :open
  end

  defp record_success(state) do
    %{
      state
      | circuit_breaker_state: :closed,
        failure_count: 0,
        last_failure_time: nil,
        last_error: nil,
        last_success: DateTime.utc_now()
    }
  end

  defp record_failure(state, reason) do
    new_failure_count = state.failure_count + 1
    now = DateTime.utc_now()

    new_state = %{
      state
      | failure_count: new_failure_count,
        last_failure_time: now,
        last_error: reason,
        last_success: state.last_success
    }

    if new_failure_count >= @max_failures do
      Logger.warning("Circuit breaker opened after #{new_failure_count} failures")
      {:ok, retry_timer} = :timer.send_after(@circuit_breaker_timeout, :retry_weather_service)
      %{new_state | circuit_breaker_state: :open, retry_timer: retry_timer}
    else
      new_state
    end
  end

  defp broadcast_weather_update(nil), do: :ok

  defp broadcast_weather_update(weather) do
    PubSub.broadcast(Fliplove.PubSub, topic(), {:update_weather, weather})
  rescue
    error ->
      Logger.error("Failed to broadcast weather update: #{inspect(error)}")
      :error
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

  defp get_location do
    case {System.get_env(@latitude_env), System.get_env(@longitude_env)} do
      {lat, lon} when is_binary(lat) and is_binary(lon) ->
        {:ok, String.to_float(lat), String.to_float(lon), "environment variables"}

      _ ->
        case System.get_env(@location_env) do
          location when is_binary(location) ->
            case Nominatim.resolve_location(location) do
              {:ok, {lat, lon}} ->
                {:ok, lat, lon, "Nominatim location lookup"}

              {:error, reason} ->
                Logger.warning("Failed to resolve location '#{location}' via Nominatim: #{inspect(reason)}")
                Logger.info("Falling back to IP geolocation")
                get_location_from_ip()
            end

          nil ->
            Logger.info("No location coordinates or location name in environment, falling back to IP geolocation")
            get_location_from_ip()
        end
    end
  end

  defp get_location_from_ip do
    # Configure Req with retries
    request_options = [
      # Retry on network-related errors
      retry: :transient,
      max_retries: 3,
      # Exponential backoff
      retry_delay: fn attempt ->
        trunc(:math.pow(2, attempt - 1) * 500)
      end,
      connect_options: [
        # 10 seconds timeout
        timeout: 10_000
      ]
    ]

    case Req.get(@ip_geolocation_url, request_options) do
      {:ok, %Req.Response{status: 200, body: %{"lat" => lat, "lon" => lon}}} ->
        {:ok, lat, lon, "IP geolocation"}

      {:ok, response} ->
        Logger.error("Unexpected response from IP geolocation service: #{inspect(response)}")
        {:error, "Invalid response from IP geolocation service"}

      {:error, exception} ->
        Logger.error("Failed to get location from IP after retries: #{inspect(exception)}")
        {:error, "Failed to get location from IP after retries"}
    end
  end

  def get_weather_with_timestamp(), do: GenServer.call(__MODULE__, :get_weather_with_timestamp)

  defp get_service_module do
    service =
      case System.get_env(@weather_service_env) do
        "openweather" ->
          :open_weather

        "openmeteo" ->
          :open_meteo

        nil ->
          Application.get_env(:fliplove, :weather, []) |> Keyword.get(:service, @default_service)

        other ->
          Logger.warning("Unknown weather service in environment: #{inspect(other)}, using default")
          @default_service
      end

    case service do
      :open_meteo ->
        {:ok, Fliplove.Weather.OpenMeteo}

      :open_weather ->
        {:ok, Fliplove.Weather.OpenWeather}

      other ->
        Logger.error("Unknown weather service configured: #{inspect(other)}")
        {:error, :invalid_service}
    end
  end
end
