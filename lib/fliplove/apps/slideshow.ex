defmodule Fliplove.Apps.Slideshow do
  @moduledoc """
  Show a slide show on the flipboard
  """
  use Fliplove.Apps.Base
  alias Fliplove.Display
  require Logger

  defstruct [:all_images, remaining: nil]

  def init_app(_opts) do
    all_images = Fliplove.Images.load_slideshow_images(width: Display.width(), height: Display.height())
    remaining = all_images
    :timer.send_after(0, __MODULE__, :next_slide)
    {:ok, %__MODULE__{all_images: all_images, remaining: remaining}}
  end

  # server functions

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
