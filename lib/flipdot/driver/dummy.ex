defmodule Flipdot.Fluepdot.Dummy do
  @doc """
  Dummy driver for Fluepdot Display that does nothing but logging
  """
  use GenServer
  require Logger

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
