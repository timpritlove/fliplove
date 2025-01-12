defmodule Fliplove.Apps.Timetable do
  use Fliplove.Apps.Base
  alias Fliplove.Display
  alias Fliplove.Font.{Library, Renderer}
  alias Fliplove.Bitmap
  require Logger

  @refresh_interval 20_000 # 20 seconds
  @api_base_url "https://v6.bvg.transport.rest"
  @stop_name_cleanup [
    {"(Berlin)", :end},    # Remove "(Berlin)" at the end of names
    {"S+U ", :start},      # Remove "S+U " at the start
    {"S ", :start},         # Remove "S " at the start
    {"U ", :start}     # Remove "S+U " at the start
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
  """
  defstruct [:timer, :stop_id, :last_departures]

  def init_app(_opts) do
    case System.get_env("FLIPLOVE_TIMETABLE_STOP") do
      nil ->
        Logger.error("FLIPLOVE_TIMETABLE_STOP environment variable not set")
        {:ok, %__MODULE__{}}

      stop_id ->
        Logger.info("Starting timetable app for stop #{stop_id}")
        timer = schedule_refresh()
        state = %__MODULE__{timer: timer, stop_id: stop_id}
        update_display(state)
        {:ok, state}
    end
  end

  def handle_info(:refresh, %__MODULE__{} = state) do
    # Cancel old timer if it exists
    if state.timer, do: Process.cancel_timer(state.timer)

    # Update display and schedule next refresh
    new_state = update_display(state)
    timer = schedule_refresh()

    {:noreply, %__MODULE__{new_state | timer: timer}}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp update_display(%__MODULE__{stop_id: stop_id, last_departures: last_departures} = state) do
    case fetch_departures(stop_id) do
      {:ok, departures} ->
        render_departures(departures)
        %__MODULE__{state | last_departures: departures}

      {:error, reason} ->
        Logger.error("Failed to fetch departures: #{inspect(reason)}")
        # On error, render last known departures if available
        if last_departures do
          render_departures(last_departures)
        end
        state
    end
  end

  defp fetch_departures(stop_id) do
    url = "#{@api_base_url}/stops/#{stop_id}/departures?duration=30"
    Logger.debug("Fetching departures from #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug("Got response: #{body}")

        case Jason.decode(body) do
          {:ok, %{"departures" => departures}} when is_list(departures) ->
            Logger.debug("Found #{length(departures)} departures")
            sorted_departures = departures
              |> Enum.sort_by(& &1["when"])
              |> Enum.take(2)
            {:ok, sorted_departures}
          {:ok, response} ->
            Logger.error("Unexpected response format: #{inspect(response)}")
            {:error, "Unexpected response format"}
          {:error, error} ->
            Logger.error("JSON decode error: #{inspect(error)}")
            {:error, "JSON decode error"}
        end

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        Logger.error("HTTP #{status}: #{body}")
        {:error, "HTTP #{status}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp clean_stop_name(name) do
    Enum.reduce(@stop_name_cleanup, name, fn {pattern, position}, acc ->
      regex = case position do
        :start -> ~r/^#{Regex.escape(pattern)}/
        :end -> ~r/#{Regex.escape(pattern)}$/
        :any -> ~r/#{Regex.escape(pattern)}/
      end
      Regex.replace(regex, acc, "")
    end)
    |> String.trim()
  end

  defp render_departures(departures) do
    font = Library.get_font_by_name("flipdot_condensed")
    bitmap = Bitmap.new(Display.width(), Display.height())

    departures
    |> Enum.with_index()
    |> Enum.reduce(bitmap, fn {departure, index}, acc ->
      y_pos = index * 8 # Each row is 8 pixels high

      # Format departure info
      line = departure["line"]["name"]
      destination = departure["destination"]["name"] |> clean_stop_name()
      when_str = format_time_until(departure["when"])
      Logger.debug("Rendering line=#{line} dest=#{destination} time=#{when_str}")

      # Render line number at x=0
      acc = Renderer.render_text(acc, {0, y_pos}, font, line)
      Logger.debug("Rendered line number")

      # Render destination starting at x=18, cropped to 70px width
      dest_bitmap = Bitmap.new(74, 8)
      |> Renderer.render_text({0, 0}, font, destination)
      acc = Bitmap.overlay(acc, dest_bitmap, [cursor_x: 18, cursor_y: y_pos])
      Logger.debug("Rendered destination")

      # Render time right-aligned, using top/bottom based on index
      valign = if index == 0, do: :top, else: :bottom
      acc = Renderer.place_text(acc, font, when_str,
        align: :right,
        valign: valign
      )
      Logger.debug("Rendered time")

      acc
    end)
    |> Display.set()
  end

  defp format_time_until(when_str) do
    Logger.debug("Formatting time for: #{when_str}")

    case DateTime.from_iso8601(when_str) do
      {:ok, departure_time, _offset} ->
        now = DateTime.now!("Etc/UTC")
        diff = DateTime.diff(departure_time, now, :minute)

        cond do
          diff <= 0 -> "0m"
          diff < 60 -> "#{diff}m"
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
end
