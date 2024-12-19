defmodule FlipdotWeb.FlipdotLive do
  use FlipdotWeb, :live_view
  require Logger

  alias Flipdot.Display
  alias Flipdot.Font.Renderer
  alias Flipdot.Font.Library
  alias Bitmap.Maze
  alias Bitmap.GameOfLife

  require Integer

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(250, self(), :tick)
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Display.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Library.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.TelegramBot.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.App.topic())
    end

    socket =
      socket
      |> assign(page_title: "Flipdot Display")
      |> assign(:bitmap, Display.get())
      |> assign(:clock, clock())
      |> assign(:app, Flipdot.App.running_app())
      |> assign(:text, "")
      |> assign(:font_name, nil)
      |> assign(:mode, :pencil)
      |> assign(:prev_xy, nil)
      |> assign(:font_select, Library.get_fonts() |> build_font_select())
      |> allow_upload(:frame, accept: ~w(.txt), max_entries: 1, max_file_size: 5_000)

    {:ok, socket}
  end

  @impl true
  def handle_info({:bot_update, update}, socket) do
    Logger.debug("Got message: #{inspect(update)}")

    Display.clear()
    |> Renderer.render_text(
      {0, 2},
      Library.get_font_by_name("flipdot"),
      update["message"]["chat"]["first_name"] <> ": " <> update["message"]["text"]
    )
    |> Display.set()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:display_updated, bitmap}, socket) do
    {:noreply, assign(socket, :bitmap, bitmap)}
  end

  @impl true
  def handle_info({:bitmap, bitmap}, socket) do
    {:noreply, assign(socket, :bitmap, bitmap)}
  end

  @impl true
  def handle_info({:running_app, app}, socket) do
    {:noreply,
     socket
     |> assign(:app, app)}
  end

  @impl true
  def handle_info(:font_library_update, socket) do
    font_select = Library.get_fonts() |> build_font_select()

    {:noreply,
     socket
     |> assign(:font_select, font_select)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:clock, clock())}
  end

  @impl true
  def handle_event("translate-up", _params, socket) do
    Display.get() |> Bitmap.translate({0, 1}) |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("translate-down", _params, socket) do
    Display.get() |> Bitmap.translate({0, -1}) |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("translate-right", _params, socket) do
    Display.get() |> Bitmap.translate({1, 0}) |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("translate-left", _params, socket) do
    Display.get() |> Bitmap.translate({-1, 0}) |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("flip-horizontally", _params, socket) do
    Display.get() |> Bitmap.flip_horizontally() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("flip-vertically", _params, socket) do
    Display.get() |> Bitmap.flip_vertically() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("invert", _params, socket) do
    Display.get() |> Bitmap.invert() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("random", _params, socket) do
    Bitmap.random(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("game-of-life", _params, socket) do
    Display.get() |> GameOfLife.game_of_life() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("gradient-h", _params, socket) do
    Display.get() |> Bitmap.gradient_h() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("gradient-v", _params, socket) do
    Display.get() |> Bitmap.gradient_v() |> Display.set()
    {:noreply, socket}
  end

  @impl true
  def handle_event("maze", _params, socket) do
    display_width = Display.width()
    display_height = Display.height()
    maze_width = if Integer.is_odd(display_width), do: display_width, else: display_width - 1
    maze_height = if Integer.is_odd(display_height), do: display_height, else: display_height - 1

    Maze.generate_maze(maze_width, maze_height)
    |> Bitmap.crop_relative(display_width, display_height, rel_y: :top)
    |> Display.set()

    {:noreply, socket}
  end

  @impl true
  def handle_event("render-text", %{"text" => text, "font" => font_name} = _params, socket) do
    Display.clear()
    |> Renderer.render_text({0, 2}, Library.get_font_by_name(font_name), text)
    |> Display.set()

    socket =
      socket
      |> assign(:text, text)
      |> assign(font_name: font_name)

    {:noreply, socket}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    [bitmap] =
      consume_uploaded_entries(socket, :frame, fn %{path: path} = _meta, _entry ->
        {:ok, Bitmap.from_file(path)}
      end)

    Flipdot.Display.set(bitmap)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("mode", params, socket) do
    new_mode = String.to_atom(params["value"])

    socket =
      if socket.assigns.mode != new_mode do
        socket
        |> assign(:prev_xy, nil)
        |> assign(:mode, new_mode)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("app", params, socket) do
    app = String.to_atom(params["value"])

    if app == Flipdot.App.running_app() do
      Flipdot.App.stop_app()
    else
      Flipdot.App.start_app(app)
    end

    socket = socket |> assign(:app, Flipdot.App.running_app())
    {:noreply, socket}
  end

  @impl true
  def handle_event("image", %{"value" => value}, socket) do
    case value do
      "" -> {:noreply, socket}
      "random" -> Bitmap.random(Display.width(), Display.height()) |> Display.set()
      "gradient-h" -> Display.get() |> Bitmap.gradient_h() |> Display.set()
      "gradient-v" -> Display.get() |> Bitmap.gradient_v() |> Display.set()
      "maze" ->
        display_width = Display.width()
        display_height = Display.height()
        maze_width = if Integer.is_odd(display_width), do: display_width, else: display_width - 1
        maze_height = if Integer.is_odd(display_height), do: display_height, else: display_height - 1

        Maze.generate_maze(maze_width, maze_height)
        |> Bitmap.crop_relative(display_width, display_height, rel_y: :top)
        |> Display.set()
      "game-of-life" -> Display.get() |> GameOfLife.game_of_life() |> Display.set()
      image when image in ["space-invaders", "pacman", "metaebene", "blinkenlights", "fluepdot"] ->
        Display.set(Flipdot.Images.images()[image])
      _ -> {:noreply, socket}
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("erase", _params, socket) do
    Bitmap.new(Display.width(), Display.height()) |> Display.set()

    {:noreply, socket}
  end

  @impl true
  def handle_event("pixel", params, socket) do
    x = String.to_integer(params["x"])
    y = String.to_integer(params["y"])

    do_pixel_click(socket.assigns.mode, {x, y}, socket.assigns.prev_xy, Display.get())
    |> Display.set()

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

    socket =
      socket
      |> assign(:prev_xy, prev_xy)
      |> assign(:bitmap, Display.get())

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

  def do_pixel_click(_mode, _coords, _prev_xy, bitmap) do
    bitmap
  end

  def clock do
    DateTime.now!("Europe/Berlin", Tz.TimeZoneDatabase)
    |> Calendar.strftime("%c", preferred_datetime: "%d.%m.%Y %H:%M:%S")
  end

  def build_font_select(fonts) do
    font_list =
      Enum.map(fonts, fn font ->
        {font.name,
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
           end,
         case Map.get(font.properties, :pixel_size) do
           nil -> "-unknown"
           pixel_size -> "-" <> Integer.to_string(pixel_size)
         end}
      end)

    font_faces =
      for {_name, face, _size} <- font_list do
        face
      end
      |> Enum.uniq()
      |> Enum.sort()

    for font_face <- font_faces do
      {font_face,
       for {name, face, size} <- font_list, font_face == face do
         {
           face <> size,
           name
         }
       end}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.display width={115} height={16} bitmap={@bitmap} />
    <div class="mt-4">
      <.tool mode={@mode} tooltip="Pencil Tool" value="pencil" self={:pencil} icon="pencil" />
      <.tool mode={@mode} tooltip="Fill Tool" value="fill" self={:fill} icon="fill" />
      <.tool mode={@mode} tooltip="Line Tool" value="line" self={:line} icon="draw-polygon" />
      <.tool mode={@mode} tooltip="Frame Tool" value="frame" self={:frame} icon="vector-square" />

      <span class="ml-4" />
      <.filter target="translate-up" tooltip="Translate UP" icon="arrow-up" />
      <.filter target="translate-down" tooltip="Translate DOWN" icon="arrow-down" />
      <.filter target="translate-left" tooltip="Translate LEFT" icon="arrow-left" />
      <.filter target="translate-right" tooltip="Translate RIGHT" icon="arrow-right" />

      <.filter target="flip-vertically" tooltip="Flip vertically" icon="arrow-down-up-across-line" />
      <.filter target="flip-horizontally" tooltip="Flip horizontally" icon="arrow-right-arrow-left" />

      <.filter target="invert" tooltip="Invert" icon="image" />
      <.filter target="erase" tooltip="Erase" icon="eraser" />
    </div>

    <div class="mt-4">
      <.app app={@app} tooltip="Dashboard" value="dashboard" self={:dashboard} icon="gauge-high" />
      <.app app={@app} tooltip="Slideshow" value="slideshow" self={:slideshow} icon="images" />
      <.app app={@app} tooltip="Maze Solver" value="maze_solver" self={:maze_solver} icon="hat-wizard" />
      <span class="ml-4" />

      <.image_button tooltip="Noise" image={Bitmap.random(16, 16)} value="random" />
      <.image_button tooltip="Gradient H" image={Bitmap.gradient_h(16, 16)} value="gradient-h" />
      <.image_button tooltip="Gradient V" image={Bitmap.gradient_v(16, 16)} value="gradient-v" />
      <.image_button tooltip="Maze" image={Maze.generate_maze(17, 17)} value="maze" />
      <.image_button tooltip="Game of Life" image={Bitmap.random(16, 16) |> GameOfLife.game_of_life()} value="game-of-life" />
    </div>
    <div class="mt-4">
      <.image_button tooltip="Space Invaders" image={Flipdot.Images.images()["space-invaders"]} value="space-invaders" />
      <.image_button tooltip="Pacman" image={Flipdot.Images.images()["pacman"]} value="pacman" />
      <.image_button tooltip="Metaebene" image={Flipdot.Images.images()["metaebene"]} value="metaebene" />
      <.image_button tooltip="Blinkenlights" image={Flipdot.Images.images()["blinkenlights"]} value="blinkenlights" />
      <.image_button tooltip="Fluepdot" image={Flipdot.Images.images()["fluepdot"]} value="fluepdot" />
    </div>
    <div>
      <.link class="rounded p-4 text-white text-l bg-indigo-600 hover:bg-indigo-900" href="/download">
        Download Display
      </.link>
    </div>
    <hr class="m-4" />
    <div id="text">
      <form phx-change="render-text" phx-submit="render-text">
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
          <%= Phoenix.HTML.Form.options_for_select(@font_select, @font_name) %>
        </select>
        <input type="submit" value="Render Text" class="rounded-full" />
      </form>
    </div>
    <form phx-submit="upload" phx-change="validate">
      <div class="container m-4" phx-drop-target={@uploads.frame.ref}>
        <FontAwesome.LiveView.icon name="file-arrow-up" type="solid" class="h-8 w-8" />
        <.live_file_input upload={@uploads.frame} />
      </div>
      <input type="submit" value="Upload File" class="rounded-full" />
    </form>

    <div class="mt-20 w-10/12 bg-black m-4 p-8">
      <div class="font-mono font-bold text-5xl text-green-500 text-center align-middle">
        <%= @clock %>
      </div>
    </div>
    """
  end

  def display(assigns) do
    ~H"""
    <div id="display" class="p-4 bg-gray-700 mt-0 ml-0">
      <div :for={y <- (@height - 1)..0} id={"row-#{y}"} class="flex">
        <div
          :for={x <- 0..(@width - 1)}
          id={"cell-#{x},#{y}"}
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
      </div>
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

  def app(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="rounded fill-white text-l bg-indigo-600 p-4 hover:bg-indigo-900 inline-block"
      phx-click="app"
      value={@value}
    >
      <div class={if @app == @self, do: "fill-yellow-300"}>
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
      class="rounded px-2 py-4 fill-white bg-indigo-600 hover:bg-indigo-900 inline-flex items-center justify-center"
      phx-click="image"
      value={@value}
    >
      <div class="h-8 flex items-center justify-center overflow-visible">
        <%= raw(Bitmap.to_svg(@image, scale: 2)) %>
      </div>
    </button>
    """
  end
end
