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
    :hourly_forecast,
    :last_error,
    :last_success,
    # Consumer tracking (pid => mref); fetch only when map is non-empty
    :consumers,
    # In-flight fetch: {ref, task_pid, mref} or nil
    :in_flight,
    # Circuit breaker state
    :circuit_breaker_state,
    :failure_count,
    :last_failure_time,
    :retry_timer
  ]

  # Hours of forecast to fetch per update (current + forecast in one Task)
  @forecast_hours 73

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

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Register the calling process as a consumer. Weather will fetch from the API
  while at least one consumer is active. The caller is monitored; when it exits,
  it is automatically removed (no need to call deactivate on crash).
  """
  def activate do
    GenServer.call(__MODULE__, :activate, @call_timeout)
  end

  @doc """
  Unregister the calling process as a consumer. When the last consumer
  deactivates, Weather stops fetching from the API.
  """
  def deactivate do
    GenServer.call(__MODULE__, :deactivate, @call_timeout)
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

  @impl GenServer
  def init(_opts) do
    Logger.debug("Initializing Weather service...")

    base_state = %__MODULE__{
      timer: nil,
      consumers: %{},
      in_flight: nil,
      hourly_forecast: nil
    }

    with {:ok, service_module} <- get_service_module(),
         {:ok, lat, lon, source} <- get_location() do
      service_name = service_module |> Module.split() |> List.last()
      Logger.debug("Selected weather service: #{service_name}")
      Logger.debug("Location: #{lat}, #{lon} (source: #{source})")

      update_interval = service_module.get_update_interval()
      Logger.debug("Weather update interval: #{update_interval}ms")

      # No timer yet; fetching starts when the first consumer calls activate()
      initial_state = %{
        base_state
        | service_module: service_module,
          latitude: lat,
          longitude: lon,
          circuit_breaker_state: :closed,
          failure_count: 0,
          last_failure_time: nil,
          retry_timer: nil
      }

      Logger.info("Weather service enabled: #{service_name}")
      Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

      {:ok, initial_state}
    else
      {:error, reason} ->
        Logger.error("Failed to initialize weather service: #{inspect(reason)}")
        Logger.info("Starting weather service in degraded mode, will retry initialization")
        {:ok, retry_timer} = :timer.send_after(@retry_interval, :retry_initialization)

        {:ok,
         %{
           base_state
           | circuit_breaker_state: :open,
             failure_count: @max_failures,
             last_failure_time: DateTime.utc_now(),
             retry_timer: retry_timer
         }}
    end
  end

  @impl GenServer
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

  @impl GenServer
  def handle_call(:activate, {pid, _tag}, state) do
    if Map.has_key?(state.consumers, pid) do
      {:reply, :ok, state}
    else
      mref = Process.monitor(pid)
      consumers = Map.put(state.consumers, pid, mref)
      new_state = %{state | consumers: consumers}

      # First consumer: start periodic timer and trigger an immediate update
      if map_size(consumers) == 1 do
        update_interval = state.service_module.get_update_interval()
        {:ok, periodic_timer} = :timer.send_interval(update_interval, :update_weather)
        {:ok, _} = :timer.send_after(1_000, :update_weather)
        {:reply, :ok, %{new_state | timer: periodic_timer}}
      else
        {:reply, :ok, new_state}
      end
    end
  end

  @impl GenServer
  def handle_call(:deactivate, {pid, _tag}, state) do
    case Map.pop(state.consumers, pid) do
      {nil, _consumers} ->
        {:reply, :ok, state}

      {mref, consumers} ->
        Process.demonitor(mref, [:flush])
        new_state = %{state | consumers: consumers}

        if map_size(consumers) == 0 and new_state.timer do
          {:ok, :cancel} = :timer.cancel(new_state.timer)
          Logger.info("Weather service deactivated (no consumers)")
          {:reply, :ok, %{new_state | timer: nil}}
        else
          {:reply, :ok, new_state}
        end
    end
  end

  @impl GenServer
  def handle_call(:get_current_weather, _from, state) do
    {:reply, state.weather, state}
  end

  @impl GenServer
  def handle_call(:get_weather_with_timestamp, _from, state) do
    {:reply, {state.weather, state.weather_timestamp}, state}
  end

  @impl GenServer
  def handle_call(:update_weather, _from, state) do
    new_state = start_fetch_if_ready(state)
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call({:get_hourly_forecast, _hours}, _from, state) do
    # Return cached forecast; no HTTP from handle_call
    forecast = state.hourly_forecast || []
    {:reply, forecast, state}
  end

  @impl GenServer
  def handle_info(:update_weather, state) do
    new_state = start_fetch_if_ready(state)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_info({:weather_result, ref, result}, state) do
    case state.in_flight do
      {^ref, _task_pid, mref} ->
        Process.demonitor(mref, [:flush])
        new_state = apply_weather_result(%{state | in_flight: nil}, result)
        {:noreply, new_state}

      _ ->
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info({:DOWN, _mref, :process, pid, _reason}, state) do
    # Consumer process exited: remove from consumers and stop timer if last
    case Map.pop(state.consumers, pid) do
      {mref, consumers} when not is_nil(mref) ->
        new_state = %{state | consumers: consumers}

        new_state =
          if map_size(consumers) == 0 and new_state.timer do
            {:ok, :cancel} = :timer.cancel(new_state.timer)
            Logger.info("Weather service deactivated (consumer process exited)")
            %{new_state | timer: nil}
          else
            new_state
          end

        {:noreply, new_state}

      {nil, _consumers} ->
        # In-flight fetch Task crashed (we get DOWN because we didn't demonitor before it died)
        case state.in_flight do
          {_ref, ^pid, mref} ->
            Process.demonitor(mref, [:flush])
            new_state = record_failure(%{state | in_flight: nil}, :task_crashed)
            {:noreply, new_state}

          _ ->
            {:noreply, state}
        end
    end
  end

  @impl GenServer
  def handle_info(:retry_initialization, state) do
    Logger.info("Retrying weather service initialization...")

    with {:ok, service_module} <- get_service_module(),
         {:ok, lat, lon, source} <- get_location() do
      service_name = service_module |> Module.split() |> List.last()
      Logger.info("Weather service initialization successful: #{service_name}")
      Logger.info("Weather service using #{source} location (#{lat}, #{lon})")

      # Reset circuit breaker; timer is started only when first consumer activates
      new_state = %{
        state
        | service_module: service_module,
          latitude: lat,
          longitude: lon,
          circuit_breaker_state: :closed,
          failure_count: 0,
          last_failure_time: nil,
          retry_timer: nil
      }

      {:noreply, new_state}
    else
      {:error, reason} ->
        Logger.warning("Weather service initialization still failing: #{inspect(reason)}")
        {:ok, retry_timer} = :timer.send_after(@retry_interval, :retry_initialization)
        {:noreply, %{state | retry_timer: retry_timer}}
    end
  end

  @impl GenServer
  def handle_info(:retry_weather_service, state) do
    Logger.debug("Retrying weather service after circuit breaker timeout")
    new_state = %{state | circuit_breaker_state: :half_open, retry_timer: nil}
    final_state = start_fetch_if_ready(new_state)
    {:noreply, final_state}
  end

  # Spawn a Task to fetch current weather + hourly forecast; only if no fetch in flight and consumers present
  defp start_fetch_if_ready(%{service_module: nil} = state) do
    Logger.debug("Weather service module not initialized, skipping update")
    state
  end

  defp start_fetch_if_ready(state) do
    cond do
      map_size(state.consumers) == 0 ->
        state

      circuit_breaker_open?(state) ->
        Logger.debug("Circuit breaker is open, skipping weather update")
        broadcast_weather_update(state.weather, state.hourly_forecast)
        state

      state.in_flight != nil ->
        state

      true ->
      ref = make_ref()
      parent = self()
      mod = state.service_module
      lat = state.latitude
      lon = state.longitude
      hours = @forecast_hours

      task =
        Task.start(fn ->
          result = fetch_weather_and_forecast(mod, lat, lon, hours)
          send(parent, {:weather_result, ref, result})
        end)

      task_pid = elem(task, 1)
      mref = Process.monitor(task_pid)
      %{state | in_flight: {ref, task_pid, mref}}
    end
  end

  defp fetch_weather_and_forecast(mod, lat, lon, hours) do
    with {:ok, weather} <- mod.get_current_weather(lat, lon),
         {:ok, forecast} <- mod.get_hourly_forecast(lat, lon, hours) do
      {:ok, weather, forecast}
    else
      {:error, _} = err -> err
    end
  end

  defp apply_weather_result(state, {:ok, weather, forecast}) do
    timestamp = DateTime.utc_now()
    Logger.debug("Weather data updated successfully")
    broadcast_weather_update(weather, forecast)
    new_state = record_success(state)
    %{new_state | weather: weather, weather_timestamp: timestamp, hourly_forecast: forecast}
  end

  defp apply_weather_result(state, {:error, reason}) do
    Logger.warning("Failed to update weather: #{inspect(reason)}")
    broadcast_weather_update(state.weather, state.hourly_forecast)
    record_failure(state, reason)
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

  defp broadcast_weather_update(weather, forecast) do
    payload = %{current: weather, forecast: forecast || []}
    PubSub.broadcast(Fliplove.PubSub, topic(), {:update_weather, payload})
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
    # Configure Req with retries; custom retry fn logs with context so logs show the source
    request_options = [
      retry: &ip_geolocation_retry/2,
      max_retries: 3,
      retry_delay: fn attempt ->
        trunc(:math.pow(2, attempt - 1) * 500)
      end,
      retry_log_level: false,
      connect_options: [
        timeout: 10_000
      ]
    ]

    case Req.run(@ip_geolocation_url, request_options) do
      {_request, %Req.Response{status: 200, body: %{"lat" => lat, "lon" => lon}}} = result ->
        req = elem(result, 0)
        retry_count = Req.Request.get_private(req, :req_retry_count, 0)
        if retry_count > 0 do
          Logger.info("IP geolocation request succeeded after #{retry_count} retries")
        end
        {:ok, lat, lon, "IP geolocation"}

      {_request, %Req.Response{} = response} ->
        Logger.error("Unexpected response from IP geolocation service: #{inspect(response)}")
        {:error, "Invalid response from IP geolocation service"}

      {_request, exception} ->
        Logger.error("Failed to get location from IP after retries: #{inspect(exception)}")
        {:error, "Failed to get location from IP after retries"}
    end
  end

  # Custom retry for IP geolocation: same as :transient but logs with "IP geolocation" context.
  defp ip_geolocation_retry(request, %Req.TransportError{reason: reason})
       when reason in [:timeout, :econnrefused, :closed] do
    log_ip_geolocation_retry(request, to_string(reason))
    true
  end

  defp ip_geolocation_retry(request, %Req.Response{status: status})
       when status in [408, 429, 500, 502, 503, 504] do
    log_ip_geolocation_retry(request, "HTTP #{status}")
    true
  end

  defp ip_geolocation_retry(request, %Req.HTTPError{protocol: :http2, reason: :unprocessed}) do
    log_ip_geolocation_retry(request, "HTTP/2 unprocessed")
    true
  end

  defp ip_geolocation_retry(_request, _response_or_exception), do: false

  defp log_ip_geolocation_retry(request, reason) do
    retry_count = Req.Request.get_private(request, :req_retry_count, 0)
    max_retries = Req.Request.get_option(request, :max_retries, 3)
    attempts_left = max_retries - retry_count
    delay_fun = Req.Request.get_option(request, :retry_delay)
    delay_ms = if is_function(delay_fun, 1), do: delay_fun.(retry_count), else: 1000
    Logger.warning(
      "IP geolocation request: retrying due to #{reason}, will retry in #{delay_ms}ms, #{attempts_left} attempts left"
    )
  end

  def get_weather_with_timestamp, do: GenServer.call(__MODULE__, :get_weather_with_timestamp)

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
