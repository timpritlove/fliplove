defmodule Flipdot.DisplayState do
  use Agent

  @topic "display_update"

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def topic, do: @topic

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def set(bitmap) do
    Phoenix.PubSub.broadcast(Flipdot.PubSub, @topic, {:display_update, bitmap})
    Agent.update(__MODULE__, fn _ -> bitmap end)
  end
end
