defmodule Fliplove.TimezoneHelper do
  @moduledoc """
  Helper functions for timezone handling
  """

  def get_system_timezone do
    {tz_string, 0} = System.cmd("date", ["+%Z"])

    case String.trim(tz_string) do
      "" -> "Etc/UTC"  # Fallback to UTC if timezone is empty
      tz -> tz  # Keep original timezone abbreviation
    end
  end
end
