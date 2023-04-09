defmodule Flipdot.Fluepdot do
  use GenServer
  alias Flipdot.PubSub
  alias Flipdot.Display
  require HTTPoison
  require Logger

  # usb mode
  @device_env "FLUEPDOT_DEV"
  @device_bitrate 115_200

  # udp mode
  @host_env "FLUEPDOT_HOST"
  @port_env "FLUEPDOT_PORT"
  @port_default 1337
  @rendering_mode_url "/rendering/mode"

  defstruct mode: nil,
            dev: nil,
            handle: nil,
            host: nil,
            port: nil,
            socket: nil,
            addresses: [],
            timer: nil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    state =
      cond do
        device = System.get_env(@device_env) ->
          case System.cmd("stty", ["-F", device, Integer.to_string(@device_bitrate)]) do
            {_result, 0} -> Logger.info("TTY settings for #{device} have been set")
            {result, status} -> Logger.warn("Can't set TTY settings: #{result} (#{status})")
          end

          {:ok, handle} = File.open(device, [:read, :write, :raw])

          %{state | mode: :usb, dev: device, handle: handle}

        host = System.get_env(@host_env) ->
          port =
            case System.get_env(@port_env) do
              nil -> @port_default
              port -> String.to_integer(port)
            end

          {:ok, v4_addresses} = :inet.getaddrs(String.to_charlist(host), :inet)
          {:ok, socket} = :gen_udp.open(0)

          {:ok, timer} = :timer.send_interval(10_000, self(), :set_rendering_mode)

          %{
            state
            | mode: :udp,
              host: host,
              port: port,
              socket: socket,
              addresses: v4_addresses,
              timer: timer
          }

        true ->
          %{state | mode: :dsummy}
      end

    Phoenix.PubSub.subscribe(PubSub, Display.topic())
    Logger.info("Fluepdot server started (mode: #{inspect(state.mode)}).")
    {:ok, state}
  end

  @impl true
  def handle_info(:set_rendering_mode, state) do
    if state.host != "localhost" do
      case HTTPoison.put(Path.join(["http://", state.host, @rendering_mode_url]), <<?1>>) do
        {:ok, response} ->
          case response.status_code do
            200 ->
              true

            status_code ->
              Logger.debug("Call to set rendering mode returned status code #{status_code}")
          end

        {:error, reason} ->
          Logger.warning("Could not set rendering mode. Reason: #{inspect(reason)}")
      end
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    case state.mode do
      :udp ->
        :gen_udp.send(
          state.socket,
          state.addresses |> List.first(),
          state.port,
          Bitmap.to_binary(bitmap)
        )

      :usb ->
        cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64()) <> "\n"

        IO.binwrite(state.handle, cmd)

      # Logger.debug("Framebuffer updated (mode: usb, handle: #{inspect(state.handle)})")

      :dummy ->
        nil
        # Logger.debug("Framebuffer updated (cmd: >dummy)")
    end

    {:noreply, state}
  end

  def handle_info(udp, state) do
    IO.inspect(udp, label: "udp")
    Logger.debug("Received confirmation UDP packet")
    {:noreply, state}
  end
end
