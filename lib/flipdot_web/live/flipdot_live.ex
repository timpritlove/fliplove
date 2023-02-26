defmodule FlipdotWeb.FlipdotLive do
  use FlipdotWeb, :live_view

  alias Flipdot.DisplayState

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(250, self(), :tick)

    Phoenix.PubSub.subscribe(Flipdot.PubSub, DisplayState.topic())

    socket =
      socket
      |> assign(page_title: "Flipdot Display")
      |> assign(:bitmap, DisplayState.get())
      |> assign(:clock, clock())

    {:ok, socket}
  end

  def handle_info({:display_update, bitmap}, socket) do
    {:noreply,
     socket
     |> assign(:bitmap, bitmap)}
  end

  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:clock, clock())}
  end

  def handle_event("toggle", params, socket) do
    x = String.to_integer(params["x"])
    y = String.to_integer(params["y"])

    DisplayState.get()
    |> Bitmap.toggle_pixel(x, y)
    |> DisplayState.set()

    {:noreply, assign(socket, :bitmap, DisplayState.get())}
  end

  def clock do
    Calendar.strftime(NaiveDateTime.utc_now(), "%c", preferred_datetime: "%d.%m.%Y %H:%M:%S")
  end
end
