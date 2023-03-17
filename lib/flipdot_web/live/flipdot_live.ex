defmodule FlipdotWeb.FlipdotLive do
  use FlipdotWeb, :live_view

  alias Flipdot.DisplayState
  alias Flipdot.Dashboard
  alias Flipdot.Font.Renderer
  alias Flipdot.Font.Library

  require Integer

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(250, self(), :tick)
      Phoenix.PubSub.subscribe(Flipdot.PubSub, DisplayState.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Library.topic())
    end

    socket =
      socket
      |> assign(page_title: "Flipdot Display")
      |> assign(:bitmap, DisplayState.get())
      |> assign(:clock, clock())
      |> assign(:text, "")
      |> assign(:tool_selection, nil)
      |> assign(:font_select, Library.get_fonts() |> build_font_select())
      |> allow_upload(:frame, accept: ~w(.txt), max_entries: 1, max_file_size: 5_000)

    {:ok, socket}
  end

  def handle_info({:display_update, bitmap}, socket) do
    {:noreply,
     socket
     |> assign(:bitmap, bitmap)}
  end

  def handle_info(:font_library_update, socket) do
    font_select = Library.get_fonts() |> build_font_select()

    {:noreply,
     socket
     |> assign(:font_select, font_select)}
  end

  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:clock, clock())}
  end

  def handle_event("translate-up", _params, socket) do
    DisplayState.get() |> Bitmap.translate({0, 1}) |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("translate-down", _params, socket) do
    DisplayState.get() |> Bitmap.translate({0, -1}) |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("translate-right", _params, socket) do
    DisplayState.get() |> Bitmap.translate({1, 0}) |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("translate-left", _params, socket) do
    DisplayState.get() |> Bitmap.translate({-1, 0}) |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("flip-horizontally", _params, socket) do
    DisplayState.get() |> Bitmap.flip_horizontally() |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("flip-vertically", _params, socket) do
    DisplayState.get() |> Bitmap.flip_vertically() |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("invert", _params, socket) do
    DisplayState.get() |> Bitmap.invert() |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("download", _params, socket) do
    DisplayState.get() |> Bitmap.invert() |> DisplayState.set()
    {:noreply, socket}
  end

  def handle_event("start-dashboard", _params, socket) do
    Dashboard.start_dashboard()

    {:noreply, socket}
  end

  def handle_event("stop-dashboard", _params, socket) do
    Dashboard.stop_dashboard()

    {:noreply, socket}
  end

  def handle_event("random", _params, socket) do
    Bitmap.random(115, 16) |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("game-of-life", _params, socket) do
    DisplayState.get() |> Bitmap.game_of_life() |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("maze", _params, socket) do
    display_width = DisplayState.width()
    display_height = DisplayState.height()
    maze_width = if Integer.is_odd(display_width), do: display_width, else: display_width - 1
    maze_height = if Integer.is_odd(display_height), do: display_height, else: display_height - 1

    Bitmap.maze(maze_width, maze_height)
    |> Bitmap.crop_relative(display_width, display_height, rel_y: :top)
    |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("toggle", params, socket) do
    x = String.to_integer(params["x"])
    y = String.to_integer(params["y"])

    DisplayState.get()
    |> Bitmap.toggle_pixel({x, y})
    |> DisplayState.set()

    {:noreply, assign(socket, :bitmap, DisplayState.get())}
  end

  def handle_event("render", %{"text" => text, "font" => font_name} = _params, socket) do
    DisplayState.clear()
    |> Renderer.render_text({0, 2}, Library.get_font_by_name(font_name), text)
    |> DisplayState.set()

    {:noreply, assign(socket, :text, text)}
  end

  def handle_event("upload", _params, socket) do
    frame =
      consume_uploaded_entries(socket, :frame, fn %{path: path} = _meta, _entry ->
        IO.inspect(path, label: "path")
        Bitmap.from_file(path)
      end)

    IO.inspect(frame, label: "frame")
    {:noreply, socket}
  end

  # helper functions
  def clock do
    DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%d.%m.%Y %H:%M:%S")
  end

  def build_font_select(fonts) do
    for font <- fonts do
      {
        font.name,
        Map.get(font.properties, :foundry, "") <>
          "-" <>
          Map.get(font.properties, :family_name, "") <>
          "-" <>
          Map.get(font.properties, :weight_name, "") <>
          "-" <>
          case Map.get(font.properties, :slant) do
            nil -> "Regular"
            "R" -> "Regular"
            "I" -> "Italic"
            "O" -> "Oblique"
          end <>
          case Map.get(font.properties, :pixel_size) do
            nil -> "-unknown"
            pixel_size -> "-" <> Integer.to_string(pixel_size)
          end
      }
    end
  end
end
