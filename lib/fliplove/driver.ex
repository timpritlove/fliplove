defmodule Fliplove.Driver do
  @moduledoc """
  Hardware driver manager for flipdot displays.

  This GenServer manages the connection to various flipdot display hardware drivers.
  It provides a unified interface for sending bitmap data to the physical display,
  regardless of the underlying connection method (WiFi, USB, dummy/simulation).

  The active driver is determined by the `FLIPLOVE_DRIVER` environment variable.

  ## Supported Drivers
  - `:fluepdot_wifi` - Network-connected FlipDot displays via WiFi
  - `:fluepdot_usb` - USB-connected FlipDot displays
  - `:dummy` - Simulation driver for testing without hardware
  - `:flipflapflop` - Alternative FlipDot implementation

  ## Example
      # Set driver via environment variable
      System.put_env("FLIPLOVE_DRIVER", "fluepdot_wifi")

      # Send bitmap to display
      bitmap = Fliplove.Bitmap.new(20, 16)
      Fliplove.Driver.set_bitmap(bitmap)
  """
  use GenServer
  alias Fliplove.Display
  alias Fliplove.PubSub
  require Logger

  # network mode
  @mode_env "FLIPLOVE_DRIVER"
  @driver %{
    fluepdot_wifi: Fliplove.Driver.FluepdotWifi,
    fluepdot_usb: Fliplove.Driver.FluepdotUsb,
    dummy: Fliplove.Driver.Dummy,
    flipflapflop: Fliplove.Driver.Flipflapflop
  }

  defstruct driver_module: :dummy, driver_pid: nil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def width do
    GenServer.call(__MODULE__, :width)
  end

  def height do
    GenServer.call(__MODULE__, :height)
  end

  @impl true
  def init(state) do
    mode_string = System.get_env(@mode_env)

    driver_module =
      case String.downcase(mode_string || "") do
        "fluepdot_usb" -> :fluepdot_usb
        "fluepdot_wifi" -> :fluepdot_wifi
        "flipflapflop" -> :flipflapflop
        _ -> :dummy
      end

    {:ok, _} =
      DynamicSupervisor.start_link(
        strategy: :one_for_one,
        name: Fliplove.Driver.DriverSupervisor
      )

    {:ok, driver_pid} = DynamicSupervisor.start_child(Fliplove.Driver.DriverSupervisor, @driver[driver_module])

    Phoenix.PubSub.subscribe(PubSub, Display.topic())
    Logger.info("Driver server started (driver: #{inspect(driver_module)}).")

    {:ok, %{state | driver_module: driver_module, driver_pid: driver_pid}}
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    send(state.driver_pid, {:display_updated, bitmap})
    {:noreply, state}
  end

  @impl true
  def handle_call(:width, _from, state) do
    driver_module = @driver[state.driver_module]
    {:reply, driver_module.width(), state}
  end

  @impl true
  def handle_call(:height, _from, state) do
    driver_module = @driver[state.driver_module]
    {:reply, driver_module.height(), state}
  end

  @impl true
  def terminate(reason, _) do
    case reason do
      :normal ->
        Logger.info("Driver terminating normally")

      :shutdown ->
        Logger.info("Driver shutting down")

      {:shutdown, _} ->
        Logger.info("Driver shutting down: #{inspect(reason)}")

      _ ->
        Logger.error("FATAL: Driver terminating unexpectedly: #{inspect(reason)}")
        Logger.error("FATAL: This may cause dependent services to restart")
    end
  end
end
