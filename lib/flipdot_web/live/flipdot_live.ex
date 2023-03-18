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
      |> assign(:mode, :pencil)
      |> assign(:prev_xy, nil)
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

  # mode selector

  def handle_event("random", _params, socket) do
    Bitmap.random(115, 16) |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("game-of-life", _params, socket) do
    DisplayState.get() |> Bitmap.game_of_life() |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("gradient-h", _params, socket) do
    DisplayState.get() |> Bitmap.gradient_h() |> DisplayState.set()

    {:noreply, socket}
  end

  def handle_event("gradient-v", _params, socket) do
    DisplayState.get() |> Bitmap.gradient_v() |> DisplayState.set()

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

  def handle_event("mode", params, socket) do
    new_mode = String.to_atom(params["value"])

    socket =
      case(socket.assigns.mode != new_mode) do
        false ->
          socket

        true ->
          case {socket.assigns.mode, new_mode} do
            {:dashboard, _} -> Dashboard.stop_dashboard()
            {_, :dashboard} -> Dashboard.start_dashboard()
            _ -> true
          end

          socket
          |> assign(:prev_xy, nil)
          |> assign(:mode, new_mode)
      end

    {:noreply, socket}
  end

  def handle_event("image", params, socket) do
    image = params["value"]
    DisplayState.set(Flipdot.Images.images()[image])

    {:noreply, socket}
  end

  def handle_event("pixel", params, socket) do
    x = String.to_integer(params["x"])
    y = String.to_integer(params["y"])

    do_pixel_click(socket.assigns.mode, {x, y}, socket.assigns.prev_xy, DisplayState.get())
    |> DisplayState.set()

    prev_xy =
      case socket.assigns.mode do
        :line ->
          {x, y}

        :frame ->
          case socket.assigns.prev_xy do
            nil -> {x, y}
            _ -> nil
          end

        _ ->
          nil
      end

    IO.inspect(prev_xy)

    socket =
      socket
      |> assign(:prev_xy, prev_xy)
      |> assign(:bitmap, DisplayState.get())

    {:noreply, socket}
  end

  # helper functions

  def do_pixel_click(:pencil, {x, y}, _, bitmap) do
    Bitmap.toggle_pixel(bitmap, {x, y})
  end

  def do_pixel_click(:fill, {x, y}, _, bitmap) do
    Bitmap.fill(bitmap, {x, y})
  end

  def do_pixel_click(:line, {x, y}, prev_xy, bitmap) do
    case prev_xy do
      nil -> bitmap
      {prev_x, prev_y} -> Bitmap.line(bitmap, {prev_x, prev_y}, {x, y})
    end
  end

  def do_pixel_click(:frame, {x, y}, prev_xy, bitmap) do
    case prev_xy do
      nil ->
        bitmap

      {prev_x, prev_y} ->
        bitmap
        |> Bitmap.line({prev_x, prev_y}, {prev_x, y})
        |> Bitmap.line({prev_x, y}, {x, y})
        |> Bitmap.line({x, y}, {x, prev_y})
        |> Bitmap.line({x, prev_y}, {prev_x, prev_y})
    end
  end

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

  def render(assigns) do
    ~H"""
    <.display width={115} height={16} bitmap={@bitmap} />
    <div class="mt-4">
      <.tool mode={@mode} tooltip="Pencil Tool" value="pencil" self={:pencil} icon="pencil" />
      <.tool mode={@mode} tooltip="Fill Tool" value="fill" self={:fill} icon="fill" />
      <.tool mode={@mode} tooltip="Line Tool" value="line" self={:line} icon="draw-polygon" />
      <.tool mode={@mode} tooltip="Frame Tool" value="frame" self={:frame} icon="vector-square" />
      <.tool mode={@mode} tooltip="Dashboard" value="dashboard" self={:dashboard} icon="gauge-high" />
    </div>

    <div class="mt-4">
      <.effect target="random">Noise</.effect>
      <.effect target="gradient-h">Gradient H</.effect>
      <.effect target="gradient-v">Gradient V</.effect>
      <.effect target="maze">Maze</.effect>
      <.effect target="game-of-life">Game of Life</.effect>
    </div>
    <div class="mt-4">
      <.filter target="translate-up" tooltip="Translate UP" icon="arrow-up" />
      <.filter target="translate-down" tooltip="Translate DOWN" icon="arrow-down" />
      <.filter target="translate-left" tooltip="Translate LEFT" icon="arrow-left" />
      <.filter target="translate-right" tooltip="Translate RIGHT" icon="arrow-right" />

      <.filter target="flip-vertically" tooltip="Flip vertically" icon="arrow-down-up-across-line" />
      <.filter target="flip-horizontally" tooltip="Flip horizontally" icon="arrow-right-arrow-left" />

      <.filter target="invert" tooltip="Invert" icon="image" />

      <.filter target="download" tooltip="Download display as text file" icon="file-arrow-down" />
    </div>
    <div class="mt-4">
      <.image_button tooltip="Space Invaders" image={Flipdot.Images.images()["space-invaders"]} value="space-invaders" />
      <.image_button tooltip="Metaebene" image={Flipdot.Images.images()["metaebene"]} value="metaebene" />
      <.image_button tooltip="Metaebene" image={Flipdot.Images.images()["fluepdot"]} value="fluepdot" />
    </div>
    <hr class="m-4" />
    <form phx-submit="upload">
      <div class="container m-4" phx-drop-target={@uploads.frame.ref}>
        <FontAwesome.LiveView.icon name="file-arrow-up" type="solid" class="h-8 w-8" />
        <.live_file_input upload={@uploads.frame} />
      </div>
      <input type="submit" value="Upload File" class="rounded-full" />
    </form>
    <div id="text">
      <form phx-change="render" phx-submit="render">
        <input
          type="text"
          name="text"
          value={@text}
          placeholder="Type some text…"
          autofocus
          autocomplete="off"
          phx-debounce="500"
        />
        <select :if={@font_select} name="font" id="font-select">
          <option :for={font <- Enum.sort_by(@font_select, fn font_entry -> elem(font_entry, 1) end)} value={elem(font, 0)}>
            <%= elem(font, 1) %>
          </option>
        </select>
        <input type="submit" value="Render Text" class="rounded-full" />
      </form>
    </div>
    <div class="mt-20 w-10/12 bg-black m-4 p-8">
      <div class="font-mono font-bold text-5xl text-green-500 text-center align-middle">
        <%= @clock %>
      </div>
    </div>
    """
  end

  def display(assigns) do
    ~H"""
    <div class="p-4 bg-gray-700 mt-0 ml-0">
      <%= for y <- (@height - 1)..0 do %>
        <div class="flex">
          <%= for x <- 0..(@width - 1) do %>
            <div
              phx-click="pixel"
              phx-value-x={x}
              phx-value-y={y}
              class={
                ["shrink-0", "w-[8px]", "h-[8px]", "flex", "items-center", "justify-around"] ++
                  [
                    if(Map.get(@bitmap.matrix, {x, y}) == 1,
                      do: "bg-[url('/images/flipdot/flipdot-pixel-on-8x8.png')]",
                      else: "bg-[url('/images/flipdot/flipdot-pixel-off-8x8.png')]"
                    )
                  ]
              }
            >
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def tool(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="fill-white bg-indigo-600 text-l px-4 py-4 rounded hover:bg-indigo-900"
      phx-click="mode"
      value={@value}
    >
      <div class={if @mode == @self, do: "fill-yellow-300"}>
        <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-8 w-8" />
      </div>
    </button>
    """
  end

  def filter(assigns) do
    ~H"""
    <button title={@tooltip} class="rounded fill-white text-l bg-indigo-600 p-4 hover:bg-indigo-900" phx-click={@target}>
      <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-8 w-8" />
    </button>
    """
  end

  def effect(assigns) do
    ~H"""
    <button class="rounded p-4 text-white text-l bg-indigo-600 hover:bg-indigo-900" phx-click={@target}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def image_button(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="rounded p-4 fill-white bg-indigo-600 hover:bg-indigo-900"
      phx-click="image"
      value={@value}
    >
      <%= raw(Bitmap.to_svg(@image)) %>
    </button>
    """
  end
end
