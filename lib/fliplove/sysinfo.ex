defmodule Fliplove.Sysinfo do
  @moduledoc """
  USB device management for Fluepdot displays.

  Provides semantic wrappers around low-level USB commands for querying and
  updating device configuration. Parsing helpers convert raw serial output into
  structured maps.

  All operations are asynchronous: commands are prepended to the priority queue
  in `FluepdotUsb`. Query responses are broadcast on `topic/0` as
  `{:usb_response, tag, text}`. Driver state changes are broadcast as
  `{:usb_driver_state, :ready | :disconnected}`.
  """

  alias Fliplove.Driver.FluepdotUsb

  @doc "PubSub topic for all sysinfo and driver state messages."
  def topic, do: FluepdotUsb.topic()

  # ---------------------------------------------------------------------------
  # Queries
  # ---------------------------------------------------------------------------

  @doc """
  Request firmware version info. Response arrives as `{:usb_response, :version, text}`.
  """
  def query_version do
    FluepdotUsb.query("show_version", :version)
  end

  @doc """
  Request current system configuration. Response arrives as `{:usb_response, :config, text}`.
  """
  def query_config do
    FluepdotUsb.query("config_show", :config)
  end

  # ---------------------------------------------------------------------------
  # Configuration changes
  # ---------------------------------------------------------------------------

  @doc """
  Set WiFi to station (client) mode with the given SSID and password,
  then save config to flash, then re-query config.

  The device must be rebooted for the change to take effect.
  """
  def save_wifi_station(ssid, password) do
    FluepdotUsb.command_sequence([
      {:display, ~s(config_wifi_station "#{escape(ssid)}" "#{escape(password)}")},
      {:display, "config_save"},
      {:query, "config_show", :config}
    ])
  end

  @doc """
  Set WiFi to access-point mode with the given SSID and password,
  then save config to flash, then re-query config.

  The device must be rebooted for the change to take effect.
  """
  def save_wifi_ap(ssid, password) do
    FluepdotUsb.command_sequence([
      {:display, ~s(config_wifi_ap "#{escape(ssid)}" "#{escape(password)}")},
      {:display, "config_save"},
      {:query, "config_show", :config}
    ])
  end

  @doc """
  Set the device hostname, then save config to flash, then re-query config.

  The device must be rebooted for the change to take effect.
  """
  def save_hostname(hostname) do
    FluepdotUsb.command_sequence([
      {:display, "config_hostname #{escape(hostname)}"},
      {:display, "config_save"},
      {:query, "config_show", :config}
    ])
  end

  @doc """
  Trigger a device reboot. The device will be unreachable for several seconds
  while it boots, then the driver will detect the prompt and broadcast
  `{:usb_driver_state, :ready}`.
  """
  def reboot do
    FluepdotUsb.command_sequence([{:display, "reboot"}])
  end

  # ---------------------------------------------------------------------------
  # Parsers
  # ---------------------------------------------------------------------------

  @doc """
  Parse the output of `show_version` into a map.

  Returns a map with string keys:
  - `"idf_version"` — ESP-IDF version string
  - `"model"` — chip model (e.g. "ESP32")
  - `"cores"` — number of cores
  - `"features"` — feature string
  - `"revision"` — chip revision number
  """
  def parse_version(text) do
    lines = String.split(text, "\n")

    idf_version =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/IDF Version:(.+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    model =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/model:(.+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    cores =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/cores:(\d+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    features =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/feature:(.+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    revision =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/revision number:(.+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    %{
      "idf_version" => idf_version,
      "model" => model,
      "cores" => cores,
      "features" => features,
      "revision" => revision
    }
  end

  @doc """
  Parse the output of `config_show` into a map.

  Returns a map with string keys:
  - `"hostname"` — device hostname
  - `"wifi_mode"` — `"ap"` or `"station"` (mode 1 = AP, mode 2 = station)
  - `"ssid"` — WiFi SSID
  - `"password"` — WiFi password
  - `"rs485_mode"` — RS485 mode integer (as string)
  - `"rs485_address"` — RS485 address
  - `"rs485_baudrate"` — RS485 baudrate
  - `"panel_count"` — number of panels (as string)
  - `"panel_sizes"` — list of panel sizes (as strings)
  - `"rendering_mode"` — rendering mode string
  """
  def parse_config(text) do
    lines = String.split(text, "\n")

    hostname =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/hostname='([^']*)'/, line) do
          [_, v] -> v
          _ -> nil
        end
      end)

    {wifi_mode, ssid, password} =
      Enum.find_value(lines, {"", "", ""}, fn line ->
        case Regex.run(~r/WiFi: mode=(\d+), ssid='([^']*)', password='([^']*)'/, line) do
          [_, mode, s, p] ->
            wifi_mode =
              case mode do
                "1" -> "ap"
                "2" -> "station"
                other -> other
              end

            {wifi_mode, s, p}

          _ ->
            nil
        end
      end)

    {rs485_mode, rs485_address, rs485_baudrate} =
      Enum.find_value(lines, {"", "", ""}, fn line ->
        case Regex.run(~r/RS485: mode=(\d+), address=(\d+|-\d+), baudrate=(\d+|-\d+)/, line) do
          [_, mode, addr, baud] -> {mode, addr, baud}
          _ -> nil
        end
      end)

    {panel_count, panel_sizes} =
      Enum.find_value(lines, {"", []}, fn line ->
        case Regex.run(~r/Flipdot: panel_count=(\d+), (.+)/, line) do
          [_, count, sizes_str] ->
            sizes =
              Regex.scan(~r/panel_size\[\d+\] = (\d+)/, sizes_str)
              |> Enum.map(fn [_, s] -> s end)

            {count, sizes}

          _ ->
            nil
        end
      end)

    rendering_mode =
      Enum.find_value(lines, "", fn line ->
        case Regex.run(~r/Flipdot rendering mode=(.+)/, line) do
          [_, v] -> String.trim(v)
          _ -> nil
        end
      end)

    %{
      "hostname" => hostname,
      "wifi_mode" => wifi_mode,
      "ssid" => ssid,
      "password" => password,
      "rs485_mode" => rs485_mode,
      "rs485_address" => rs485_address,
      "rs485_baudrate" => rs485_baudrate,
      "panel_count" => panel_count,
      "panel_sizes" => panel_sizes,
      "rendering_mode" => rendering_mode
    }
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp escape(str), do: String.replace(str, ~s("), ~s(\\"))
end
