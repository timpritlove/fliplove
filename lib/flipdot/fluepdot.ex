defmodule Flipdot.Fluepdot do
  use GenServer
  alias Flipdot.PubSub
  alias Flipdot.Display
  require HTTPoison
  require Logger

  @host_env "FLUEPDOT_HOST"
  @host_default "localhost"
  @port_env "FLUEPDOT_PORT"
  @port_default 1337
  @rendering_mode_url "/rendering/mode"

  defstruct host: nil, port: nil, socket: nil, addresses: [], timer: nil

  def start_link(_config) do
    host =
      case System.get_env(@host_env) do
        nil -> @host_default
        host -> host
      end

    port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    GenServer.start_link(__MODULE__, %__MODULE__{host: host, port: port}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, v4_addresses} = :inet.getaddrs(String.to_charlist(state.host), :inet)
    {:ok, socket} = :gen_udp.open(0)

    {:ok, timer} = :timer.send_interval(10_000, self(), :set_rendering_mode)

    Phoenix.PubSub.subscribe(PubSub, Display.topic())
    Logger.info("Fluepdot server started.")
    {:ok, %{state | socket: socket, addresses: v4_addresses, timer: timer}}
  end

  @impl true
  def handle_info(:set_rendering_mode, state) do
    if state.host != "localhost" do
      case HTTPoison.put(Path.join(["http://", state.host, @rendering_mode_url]), <<?1>>) do
        {:ok, response} ->
          case response.status_code do
            200 -> true
            status_code -> Logger.debug("Call to set rendering mode returned status code #{status_code}")
          end

        {:error, reason} ->
          Logger.warning("Could not set rendering mode. Reason: #{inspect(reason)}")
      end
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:display_update, bitmap}, state) do
    :gen_udp.send(
      state.socket,
      state.addresses |> List.first(),
      state.port,
      Bitmap.to_binary(bitmap)
    )

    {:noreply, state}
  end
end
