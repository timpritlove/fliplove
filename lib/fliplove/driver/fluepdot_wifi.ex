defmodule Fliplove.Driver.FluepdotWifi do
  @moduledoc """
  WiFi/Network driver for Fluepdot displays via UDP and HTTP.

  This GenServer driver communicates with Fluepdot displays over a network
  connection using UDP packets for bitmap data transmission and HTTP for
  configuration and status queries.

  ## Configuration
  Configure via environment variables:
  - `FLIPLOVE_HOST` - Target display IP address
  - `FLIPLOVE_PORT` - Target port (default: 1337)

  ## Features
  - Network-based bitmap transmission via UDP
  - HTTP status monitoring and configuration
  - Automatic connection retry on network failures
  - Error handling and logging

  ## Example
      # Set environment variables
      System.put_env("FLIPLOVE_HOST", "192.168.1.100")
      System.put_env("FLIPLOVE_PORT", "1337")

      # Driver will automatically connect when started
  """
  alias Fliplove.Bitmap

  @doc """
  Driver for Fluepdot Display via Network (UDP + HTTP)
  """
  use GenServer
  require HTTPoison
  require Logger

  @host_env "FLIPLOVE_HOST"
  @port_env "FLIPLOVE_PORT"
  @port_default 1337
  @retry_interval 5000

  @rendering_mode_url "/rendering/mode"

  @device_width 115
  @device_height 16

  def width, do: @device_width
  def height, do: @device_height

  defstruct counter: 0,
            host: nil,
            port: nil,
            socket: nil,
            addresses: [],
            timer: nil,
            connected: false

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    case System.get_env(@host_env) do
      nil ->
        {:stop, "#{@host_env} environment variable not set"}

      host ->
        port =
          case System.get_env(@port_env) do
            nil -> @port_default
            port -> String.to_integer(port)
          end

        Logger.info("Starting WiFi display driver, looking for device at #{host}:#{port}")
        {:ok, socket} = :gen_udp.open(0)
        {:ok, timer} = :timer.send_interval(@retry_interval, self(), :check_connection)

        state = %{
          state
          | host: host,
            port: port,
            socket: socket,
            timer: timer,
            counter: 0
        }

        send(self(), :check_connection)
        {:ok, state}
    end
  end

  def handle_info({:display_updated, bitmap}, %{connected: true} = state) do
    case :gen_udp.send(
           state.socket,
           state.addresses |> List.first(),
           state.port,
           Bitmap.to_binary(bitmap)
         ) do
      :ok ->
        counter = state.counter + 1
        Logger.debug("UDP: Display updated (##{counter}).")
        {:noreply, %{state | counter: counter}}

      {:error, reason} ->
        Logger.debug("UDP send failed: #{inspect(reason)}")
        handle_disconnect(state, "UDP send error")
    end
  end

  def handle_info({:display_updated, _bitmap}, state) do
    Logger.debug("Ignoring display update - device not connected")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:check_connection, %{connected: true} = state) do
    {:noreply, state}
  end

  def handle_info(:check_connection, state) do
    case :inet.getaddrs(String.to_charlist(state.host), :inet) do
      {:ok, addresses} when addresses != [] ->
        Logger.debug("Successfully resolved #{state.host} to #{inspect(addresses)}")

        case try_connect(state, addresses) do
          {:ok, new_state} ->
            Logger.info("Successfully connected to WiFi display at #{state.host}")
            {:noreply, new_state}

          {:error, reason} ->
            Logger.debug("Failed to initialize device: #{inspect(reason)}")
            schedule_check()
            {:noreply, %{state | addresses: [], connected: false}}
        end

      {:ok, []} ->
        Logger.debug("No IPv4 addresses found for #{state.host}")
        schedule_check()
        {:noreply, %{state | addresses: [], connected: false}}

      {:error, reason} ->
        Logger.debug("Failed to resolve #{state.host}: #{inspect(reason)}")
        schedule_check()
        {:noreply, %{state | addresses: [], connected: false}}
    end
  end

  # receive reply UDP packet
  def handle_info({:udp, _socket, _ip, _port, _data}, state) do
    Logger.debug("UDP: Received confirmation packet")
    {:noreply, state}
  end

  defp try_connect(state, addresses) do
    case HTTPoison.put(Path.join(["http://", state.host, @rendering_mode_url]), <<?1>>) do
      {:ok, %{status_code: 200}} ->
        Logger.debug("Successfully set pixel rendering mode")
        {:ok, %{state | addresses: addresses, connected: true}}

      {:ok, %{status_code: status_code}} ->
        {:error, "Failed to set pixel rendering mode. Status code: #{status_code}"}

      {:error, reason} ->
        {:error, "Failed to set pixel rendering mode: #{inspect(reason)}"}
    end
  end

  defp handle_disconnect(state, reason) do
    if state.connected do
      Logger.info("Disconnected from WiFi display: #{reason}")
    end

    {:noreply, %{state | connected: false, addresses: []}}
  end

  defp schedule_check do
    Process.send_after(self(), :check_connection, @retry_interval)
  end

  @impl GenServer
  def terminate(_reason, state) do
    if state.socket do
      :gen_udp.close(state.socket)
    end
  end
end
