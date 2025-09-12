defmodule Fliplove.Driver.Dummy do
  @moduledoc """
  Dummy driver for flipdot display simulation and testing.

  This driver provides a no-op implementation for testing and development
  without requiring actual flipdot hardware. It logs bitmap updates and
  maintains the expected driver interface.

  Useful for development, testing, and demonstrations when physical
  hardware is not available.

  ## Configuration
  - Device dimensions: 115x16 pixels
  - Logs all bitmap updates at debug level
  - No actual hardware communication
  """

  @doc """
  Dummy driver that just logs updates
  """
  use GenServer
  require Logger

  @device_width 115
  @device_height 16

  def width, do: @device_width
  def height, do: @device_height

  defstruct [:counter]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, %{state | counter: 0}}
  end

  @impl GenServer
  def handle_info({:display_updated, _bitmap}, state) do
    counter = state.counter + 1
    # Logger.debug("Dummy: Display updated (##{counter}).")
    {:noreply, %{state | counter: counter}}
  end
end
