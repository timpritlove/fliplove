defmodule Flipdot.Fluepdot do
  use GenServer
  alias Flipdot.PubSub
  alias Flipdot.Display
  require Logger

  # udp mode
  @mode_env "FLIPDOT_MODE"
  @driver %{
    udp: Flipdot.Fluepdot.UDP,
    usb: Flipdot.Fluepdot.USB,
    dummy: Flipdot.Fluepdot.Dummy
  }

  defstruct mode: :dummy, driver: nil

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    mode_string = System.get_env(@mode_env)

    mode =
      case mode_string do
        "USB" -> :usb
        "UDP" -> :udp
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
    send(self(), {:display_updated, Display.get()})
    {:ok, %{state | mode: mode, driver: driver}}
  end

  @impl true
  def handle_info({:display_updated, bitmap}, state) do
    send(state.driver, {:display_updated, bitmap})
    {:noreply, state}
  end
end
