defmodule Fliplove.Apps.Timetable do
  use Fliplove.Apps.Base
  alias Fliplove.Bitmap
  alias Fliplove.Display
  alias Fliplove.Font.{Library, Renderer}
  require Logger

  # Default refresh intervals in milliseconds
  # 1 second for the first fetch after startup
  @initial_refresh_interval 1_000
  # 60 seconds when no data or departures far away
  @default_refresh_interval 60_000
  # 30 seconds when departure is 2-3 minutes away
  @medium_refresh_interval 30_000
  # 15 seconds when departure is less than 2 minutes away
  @fast_refresh_interval 15_000
  @api_base_url "https://v6.bvg.transport.rest"
  @stop_name_cleanup [
    # Remove "(Berlin)" at the end of names
    {"(Berlin)", :end},
    # Remove "S+U " at the start
    {"S+U ", :start},
    # Remove "S " at the start
    {"S ", :start},
    # Remove "S+U " at the start
    {"U ", :start}
  ]

  @moduledoc """
  Timetable app that displays upcoming departures for a specified public transport stop.
  """

  @doc """
  GenServer state for the Timetable app.

  Fields:
  - timer: Reference to the refresh timer
  - stop_id: BVG stop ID from environment variable
  - last_departures: List of last known departures, used for fallback on API errors
  - refresh_interval: Current refresh interval in milliseconds
  """
  defstruct [:timer, :stop_id, :last_departures, refresh_interval: @default_refresh_interval]

  def init_app(_opts) do
    case System.get_env("FLIPLOVE_TIMETABLE_STOP") do
      nil ->
        Logger.error("FLIPLOVE_TIMETABLE_STOP environment variable not set")
        {:ok, %__MODULE__{}}

      stop_id ->
        Logger.info("Starting timetable app for stop #{stop_id}")
        # Start with empty display
        Display.set(Bitmap.new(Display.width(), Display.height()))

        # Create initial state with very short refresh interval for first fetch
        initial_state = %__MODULE__{
          stop_id: stop_id,
          refresh_interval: @initial_refresh_interval
        }

        timer = schedule_refresh(initial_state)

        {:ok, %__MODULE__{initial_state | timer: timer}}
    end
  end

  def handle_info(:refresh, %__MODULE__{} = state) do
    # Cancel old timer if it exists
    if state.timer, do: Process.cancel_timer(state.timer)

    # Update state with new data and timer
    new_state = refresh_state(state)

    {:noreply, new_state}
  end

  defp refresh_state(%__MODULE__{stop_id: stop_id, last_departures: last_departures} = state) do
    case fetch_departures(stop_id) do
      {:ok, departures} ->
        # Update display with new departures
        update_display(departures)

        # Calculate new refresh interval and schedule timer
        new_refresh_interval = calculate_refresh_interval(departures)
        new_timer = schedule_refresh(%__MODULE__{refresh_interval: new_refresh_interval})

        %__MODULE__{state | last_departures: departures, refresh_interval: new_refresh_interval, timer: new_timer}

      {:error, reason} ->
        Logger.error("Failed to fetch departures: #{inspect(reason)}")
        # On error, show last known departures if available
        if last_departures do
          update_display(last_departures)
        end

        # Schedule next retry with current interval
        new_timer = schedule_refresh(state)
        %__MODULE__{state | timer: new_timer}
    end
  end

  defp update_display(departures) do
    render_departures(departures)
  end

  defp schedule_refresh(%__MODULE__{refresh_interval: refresh_interval}) do
    Logger.debug("Scheduling next refresh in #{div(refresh_interval, 1000)} seconds")
    Process.send_after(self(), :refresh, refresh_interval)
  end

  defp calculate_refresh_interval(departures) when is_list(departures) and length(departures) > 0 do
    # Get the first departure time
    case List.first(departures) do
      %{"when" => when_str} ->
        case DateTime.from_iso8601(when_str) do
          {:ok, departure_time, _offset} ->
            now = DateTime.now!("Etc/UTC")
            minutes_until = DateTime.diff(departure_time, now, :minute)

            interval =
              cond do
                minutes_until >= 3 -> @default_refresh_interval
                minutes_until >= 2 -> @medium_refresh_interval
                true -> @fast_refresh_interval
              end

            Logger.debug(
              "Next departure in #{minutes_until} minutes, setting refresh interval to #{div(interval, 1000)} seconds"
            )

            interval

          _error ->
            Logger.debug(
              "Could not parse departure time, using default refresh interval of #{div(@default_refresh_interval, 1000)} seconds"
            )

            @default_refresh_interval
        end

      _no_when ->
        Logger.debug(
          "No departure time found, using default refresh interval of #{div(@default_refresh_interval, 1000)} seconds"
        )

        @default_refresh_interval
    end
  end

  defp calculate_refresh_interval(_) do
    Logger.debug(
      "No departures found, using default refresh interval of #{div(@default_refresh_interval, 1000)} seconds"
    )

    @default_refresh_interval
  end

  defp fetch_departures(stop_id) do
    url = "#{@api_base_url}/stops/#{stop_id}/departures?duration=30"
    Logger.debug("Fetching departures from #{url}")

    case Req.get(url) do
      {:ok, %{status: 200, body: %{"departures" => departures}}} when is_list(departures) ->
        # Log the first departure for debugging
        if length(departures) > 0 do
          Logger.debug("First departure data: #{inspect(List.first(departures))}")
        end

        # Validate departure data before sorting
        valid_departures =
          Enum.filter(departures, fn departure ->
            case departure do
              # Valid departure with real-time data
              %{"when" => when_str, "line" => %{"name" => _}, "destination" => %{"name" => _}}
              when not is_nil(when_str) ->
                true

              # Cancelled departure with planned time
              %{
                "cancelled" => true,
                "plannedWhen" => planned_when,
                "line" => %{"name" => _},
                "destination" => %{"name" => _}
              }
              when not is_nil(planned_when) ->
                true

              invalid_departure ->
                Logger.warning("Skipping invalid departure: #{inspect(invalid_departure)}")
                false
            end
          end)

        # Transform departures to include cancelled status and fallback time
        departures_with_time =
          Enum.map(valid_departures, fn departure ->
            time = departure["when"] || departure["plannedWhen"]
            Map.merge(departure, %{"effective_when" => time, "is_cancelled" => departure["cancelled"] == true})
          end)

        sorted_departures =
          departures_with_time
          |> Enum.sort_by(& &1["effective_when"])
          |> Enum.take(2)

        {:ok, sorted_departures}

      {:ok, %{status: 200, body: body}} ->
        Logger.error("Unexpected response body format: #{inspect(body)}")
        {:error, "Unexpected response format"}

      {:ok, %{status: status, body: body}} ->
        Logger.error("HTTP #{status}: #{inspect(body)}")
        {:error, "HTTP #{status}"}

      {:error, error} ->
        Logger.error("Request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp clean_stop_name(name) do
    Enum.reduce(@stop_name_cleanup, name, fn {pattern, position}, acc ->
      regex =
        case position do
          :start -> ~r/^#{Regex.escape(pattern)}/
          :end -> ~r/#{Regex.escape(pattern)}$/
          :any -> ~r/#{Regex.escape(pattern)}/
        end

      Regex.replace(regex, acc, "")
    end)
    |> String.trim()
  end

  defp render_departures([first_departure, second_departure]) do
    font = Library.get_font_by_name("flipdot_condensed")
    display = Bitmap.new(Display.width(), Display.height())

    # Render both departures separately
    first = render_departure(first_departure, font)
    second = render_departure(second_departure, font)

    # Place first departure at top (y=8), second at bottom (y=0)
    display
    |> Bitmap.overlay(first, cursor_y: 8)
    |> Bitmap.overlay(second, cursor_y: 0)
    |> Display.set()
  end

  defp render_departures([single_departure]) do
    # Handle case with only one departure by showing it at the bottom
    font = Library.get_font_by_name("flipdot_condensed")
    display = Bitmap.new(Display.width(), Display.height())

    single = render_departure(single_departure, font)

    display
    |> Bitmap.overlay(single, cursor_y: 8)
    |> Display.set()
  end

  defp render_departures([]) do
    # Handle empty departures list
    Display.set(Bitmap.new(Display.width(), Display.height()))
  end

  defp render_departure(departure, font) do
    bitmap = Bitmap.new(Display.width(), 8)

    # Format departure info
    line = departure["line"]["name"]
    destination = departure["destination"]["name"] |> clean_stop_name()

    # Use effective_when for time display and add cancelled indicator
    when_str =
      if departure["is_cancelled"] do
        "X" <> format_time_until(departure["effective_when"])
      else
        format_time_until(departure["effective_when"])
      end

    # Render line number at x=0
    bitmap = Renderer.render_text(bitmap, {0, 0}, font, line)

    # Render destination
    dest_bitmap =
      Bitmap.new(90, 8)
      |> Renderer.render_text({0, 0}, font, destination)

    bitmap = Bitmap.overlay(bitmap, dest_bitmap, cursor_x: 15)

    # Render time right-aligned
    Renderer.place_text(bitmap, font, when_str, align: :right)
  end

  defp format_time_until(nil) do
    Logger.warning("Received nil departure time")
    "??"
  end

  defp format_time_until(when_str) when is_binary(when_str) do
    case DateTime.from_iso8601(when_str) do
      {:ok, departure_time, _offset} ->
        now = DateTime.now!("Etc/UTC")
        diff = DateTime.diff(departure_time, now, :minute)

        cond do
          diff <= 0 ->
            "0 min"

          diff < 60 ->
            "#{diff} min"

          true ->
            # For departures more than 60 minutes away, show the actual time
            departure_time
            |> DateTime.shift_zone!("Europe/Berlin")
            |> Calendar.strftime("%H:%M")
        end

      error ->
        Logger.error("Time formatting failed: #{inspect(error)}")
        "??"
    end
  end

  defp format_time_until(invalid) do
    Logger.error("Invalid departure time format: #{inspect(invalid)}")
    "??"
  end

  @impl Fliplove.Apps.Base
  def cleanup_app(_reason, state) do
    Logger.debug("Timetable cleanup_app called")
    if state.timer, do: Process.cancel_timer(state.timer)
    :ok
  end
end
