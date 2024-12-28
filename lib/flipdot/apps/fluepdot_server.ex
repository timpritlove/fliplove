defmodule Flipdot.Apps.FluepdotServer do
  @moduledoc """
  Simulates a Fluepdot display server that receives bitmap updates via UDP.
  """
  use GenServer
  alias Flipdot.{Bitmap, Display}
  require Logger

  @port_env "FLIPDOT_PORT"
  @port_default 1337

  def start_link(_) do
    # Register as running app
    Registry.register(Flipdot.Apps.Registry, :running_app, :fluepdot_server)
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    Logger.info("Fluepdot Server listening on UDP port #{port}")

    {:ok, %{socket: socket}}
  end

  @impl true
  def handle_info({:udp, _socket, _address, _port, data}, state) do
    Logger.debug("Received UDP packet")

    # Convert binary data to bitmap and update display
    data
    |> Bitmap.from_binary(Display.width(), Display.height())
    |> Display.set()

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{socket: socket}) do
    :gen_udp.close(socket)
  end

  @doc """
  Sends a bitmap to a Fluepdot display server via UDP.
  Returns :ok on success or {:error, reason} on failure.
  """
  def send_bitmap(bitmap, host, port \\ @port_default) do
    with {:ok, socket} <- :gen_udp.open(0, [:binary]),
         binary_data <- Bitmap.to_binary(bitmap),
         :ok <- :gen_udp.send(socket, String.to_charlist(host), port, binary_data) do
      :gen_udp.close(socket)
      :ok
    else
      {:error, reason} = error ->
        Logger.error("Failed to send bitmap: #{inspect(reason)}")
        error
    end
  end
end
