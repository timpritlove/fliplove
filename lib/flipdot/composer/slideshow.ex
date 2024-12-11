defmodule Flipdot.Composer.Slideshow do
  @moduledoc """
  Show a slide show on the flipboard
  """
  use GenServer
  alias Flipdot.Display
  require Logger

  @registry Flipdot.Composer.Registry

  defstruct [:all_images, remaining: nil]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # server functions

  @impl true
  def init(state) do
    Registry.register(@registry, :running_composer, :slideshow)

    all_images = Flipdot.Images.images() |> Map.values()
    remaining = all_images
    :timer.send_after(0, __MODULE__, :next_slide)
    Logger.info("Slideshow has been started.")
    {:ok, %{state | all_images: all_images, remaining: remaining}}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Slideshow has been shut down.")
  end

  @impl true
  def handle_info(:next_slide, state) do
    remaining =
      case state.remaining do
        [next_image | remaining_images] ->
          Display.set(next_image)
          remaining_images

        [] ->
          state.all_images
      end

    :timer.send_after(15_000, __MODULE__, :next_slide)

    {:noreply, %{state | remaining: remaining}}
  end
end
