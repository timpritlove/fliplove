defmodule Fliplove.TimezoneHelper do
  @moduledoc """
  Helper functions for timezone handling.
  Provides UTC offset in minutes for the configured timezone.
  """

  require Logger

  @timezone_env "FLIPLOVE_TIMEZONE"

  @doc """
  Get the timezone offset in minutes relative to UTC.
  Positive values mean ahead of UTC, negative values mean behind UTC.
  Resolution order:
  1. FLIPLOVE_TIMEZONE environment variable
  2. Application config
  3. System timezone offset
  """
  def get_utc_offset_minutes do
    # Try environment variable first
    case System.get_env(@timezone_env) do
      nil ->
        # Try application config next
        case Application.get_env(:fliplove, :timezone) do
          nil -> get_system_offset_minutes()  # Fallback to system timezone if no config
          :system -> get_system_offset_minutes()  # Explicitly use system timezone
          offset when is_binary(offset) -> parse_offset_minutes(offset)  # Parse configured offset
          _ -> get_system_offset_minutes()  # Fallback for invalid config values
        end
      offset -> parse_offset_minutes(offset)  # Environment variable takes precedence
    end
  end

  defp get_system_offset_minutes do
    # Get the timezone offset from the system
    {offset_str, 0} = System.cmd("date", ["+%z"])
    parse_offset_minutes(offset_str)
  end

  # Parse offset strings in various formats to minutes
  defp parse_offset_minutes(offset) when is_binary(offset) do
    case Regex.run(~r/^([+-])(\d{2}):?(\d{2})$/, String.trim(offset)) do
      [_, sign, hours, mins] ->
        minutes = String.to_integer(hours) * 60 + String.to_integer(mins)
        case sign do
          "+" -> minutes
          "-" -> -minutes
        end
      _ ->
        Logger.warning("Invalid timezone offset format: #{inspect(offset)}, falling back to UTC")
        0  # fallback to UTC
    end
  end
  defp parse_offset_minutes(_), do: 0  # fallback to UTC for non-binary input
end
