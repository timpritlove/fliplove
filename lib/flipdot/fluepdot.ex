defmodule Flipdot.Fluepdot do
  use GenServer
  alias Flipdot.PubSub
  alias Flipdot.Display
  require Logger

  # network mode
  @mode_env "FLIPDOT_MODE"
  @driver %{
    network: Flipdot.Fluepdot.Network,
    usb: Flipdot.Fluepdot.USB,
    dummy: Flipdot.Fluepdot.Dummy,
    flipflapflop: Flipdot.Fluepdot.Flipflapflop
  }

  defstruct mode: :dummy, driver: nil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    mode_string = System.get_env(@mode_env)

    mode =
      case String.downcase(mode_string || "") do
        "usb" -> :usb
        "network" -> :network
        "flipflapflop" -> :flipflapflop
        _ -> :dummy
      end

    {:ok, _} =
      DynamicSupervisor.start_link(
        strategy: :one_for_one,
        name: Flipdot.Fluepdot.DriverSupervisor
      )

    {:ok, driver} = DynamicSupervisor.start_child(Flipdot.Fluepdot.DriverSupervisor, @driver[mode])

    Phoenix.PubSub.subscribe(PubSub, Display.topic())
    Logger.info("Fluepdot server started (mode: #{inspect(mode)}).")

    # Start with a blank display
    Display.clear()

    {:ok, %{state | mode: mode, driver: driver}}
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    send(state.driver, {:display_updated, bitmap})
    {:noreply, state}
  end
end
