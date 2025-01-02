defmodule Flipdot.Driver.Dummy do

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

  @impl true
  def init(state) do
    {:ok, %{state | counter: 0}}
  end

  @impl true
  def handle_info({:display_updated, _bitmap}, state) do
    counter = state.counter + 1
    # Logger.debug("Dummy: Display updated (##{counter}).")
    {:noreply, %{state | counter: counter}}
  end
end
