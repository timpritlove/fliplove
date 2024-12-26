defmodule FlipdotWeb.FlipdotLive do
  use FlipdotWeb, :live_view
  alias Flipdot.Bitmap
  alias Flipdot.Display
  alias Flipdot.Font.Renderer
  alias Flipdot.Font.Library
  alias Flipdot.Bitmap.Maze
  alias Flipdot.Bitmap.GameOfLife

  require Logger
  require Integer

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(250, self(), :tick)
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Display.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Library.topic())
      Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.TelegramBot.topic())
    end

    socket =
      socket
      |> assign(page_title: "Flipdot Display")
      |> assign(:bitmap, Display.get())
      |> assign(:clock, clock())
      |> assign(:app, Flipdot.Apps.running_app())
      |> assign(:text, "")
      |> assign(:font_name, "flipdot")
      |> assign(:mode, :pencil)
      |> assign(:prev_xy, nil)
      |> assign(:font_select, Library.get_fonts() |> build_font_select())
      |> assign(:usb_mode?, System.get_env("FLIPDOT_MODE") == "USB")
      |> allow_upload(:frame,
        accept: ~w(.txt),
        max_entries: 1,
        max_file_size: 5_000,
        auto_upload: true,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  # Handle upload progress
  defp handle_progress(:frame, entry, socket) do
    if entry.done? do
      Logger.debug("Upload completed, processing file...")
      consume_uploaded_entries(socket, :frame, fn %{path: path}, _entry ->
        Logger.debug("Reading file from path: #{path}")
        bitmap = Bitmap.from_file(path)
        Logger.debug("Setting bitmap to display")
        Display.set(bitmap)
        {:ok, bitmap}
      end)
    end

    {:noreply, socket}
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
    fonts = Library.get_fonts()
    font_select = build_font_select(fonts)

    font_name = if Enum.any?(fonts, &(&1.name == socket.assigns.font_name)),
      do: socket.assigns.font_name,
      else: "flipdot"

    {:noreply,
     socket
     |> assign(:font_select, font_select)
     |> assign(:font_name, font_name)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:clock, clock())
     |> assign(:app, Flipdot.Apps.running_app())}
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
    font = Library.get_font_by_name(font_name)

    # Create a fresh display-sized bitmap and place the normalized text centered on it
    bitmap =
      Bitmap.new(Display.width(), Display.height())
      |> Renderer.place_text(font, text, align: :center, valign: :middle)

    Display.set(bitmap)

    socket =
      socket
      |> assign(:text, text)
      |> assign(:font_name, font_name)
      |> assign(:bitmap, Display.get())

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

    if app == Flipdot.Apps.running_app() do
      Flipdot.Apps.stop_app()
    else
      Flipdot.Apps.start_app(app)
    end

    socket = socket |> assign(:app, Flipdot.Apps.running_app())
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

  @impl true
  def handle_event("download", _params, socket) do
    bitmap_text = Display.get() |> Bitmap.to_text()

    {:noreply,
     socket
     |> push_event("download", %{
       filename: "bitmap.txt",
       content: bitmap_text,
       mime_type: "text/plain"
     })}
  end

  @impl true
  def handle_event("usb-command", %{"command" => command}, socket) do
    GenServer.cast(Flipdot.Fluepdot.USB, {:command, command})
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
    fonts
    |> Enum.map(fn font ->
      # Create a more concise display name
      display_name = [
        Map.get(font.properties, :family_name, ""),
        Map.get(font.properties, :weight_name, ""),
        case Map.get(font.properties, :slant) do
          nil -> nil
          "R" -> nil
          "I" -> "Italic"
          "O" -> "Oblique"
        end,
        case Map.get(font.properties, :pixel_size) do
          nil -> nil
          size -> "#{size}px"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

      # Group by foundry and family name
      group_name = Map.get(font.properties, :foundry, "Other")

      {
        group_name,
        {display_name, font.name}
      }
    end)
    |> Enum.group_by(
      fn {group, _} -> group end,
      fn {_, font_info} -> font_info end
    )
    |> Enum.sort_by(fn {group, _} -> group end)
    |> Enum.map(fn {group, fonts} ->
      {group, Enum.sort_by(fonts, fn {display, _} -> display end)}
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-900 text-white p-8 absolute inset-0">
      <div id="download-hook" phx-hook="Download"></div>

      <%!-- Centered Display --%>
      <div class="flex flex-col items-center mb-8">
        <.display width={115} height={16} bitmap={@bitmap} />
        <button
          class="mt-4 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg flex items-center gap-2"
          phx-click="download"
        >
          <FontAwesome.LiveView.icon name="download" type="solid" class="h-5 w-5" />
          <span>Download Display</span>
        </button>
      </div>

      <div class="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
        <%!-- Left Column --%>
        <div class="space-y-6">
          <%!-- Tools Section --%>
          <.section title="Drawing Tools" class="flex gap-2">
            <.tool mode={@mode} tooltip="Pencil Tool" value="pencil" self={:pencil} icon="pencil" />
            <.tool mode={@mode} tooltip="Fill Tool" value="fill" self={:fill} icon="fill" />
            <.tool mode={@mode} tooltip="Line Tool" value="line" self={:line} icon="draw-polygon" />
            <.tool mode={@mode} tooltip="Frame Tool" value="frame" self={:frame} icon="vector-square" />
          </.section>

          <%!-- Modifiers Section --%>
          <.section title="Modifiers">
            <.button_group>
              <.filter target="translate-up" tooltip="Translate UP" icon="arrow-up" />
              <.filter target="translate-down" tooltip="Translate DOWN" icon="arrow-down" />
              <.filter target="translate-left" tooltip="Translate LEFT" icon="arrow-left" />
              <.filter target="translate-right" tooltip="Translate RIGHT" icon="arrow-right" />
              <.filter target="flip-vertically" tooltip="Flip vertically" icon="arrow-down-up-across-line" />
              <.filter target="flip-horizontally" tooltip="Flip horizontally" icon="arrow-right-arrow-left" />
              <.filter target="invert" tooltip="Invert" icon="image" />
              <.filter target="erase" tooltip="Erase" icon="eraser" />
              <.filter target="game-of-life" tooltip="Game of Life" icon="chess-board" />
            </.button_group>
          </.section>

          <%!-- Apps Section --%>
          <.section title="Apps">
            <.button_group>
              <.app app={@app} tooltip="Dashboard" value="dashboard" self={:dashboard} icon="gauge-high" />
              <.app app={@app} tooltip="Slideshow" value="slideshow" self={:slideshow} icon="images" />
              <.app app={@app} tooltip="Maze Solver" value="maze_solver" self={:maze_solver} icon="hat-wizard" />
              <.app app={@app} tooltip="Symbols" value="symbols" self={:symbols} icon="icons" />
            </.button_group>
          </.section>

          <%!-- USB Commands Section --%>
          <.section :if={@usb_mode?} title="USB Commands">
            <.button_group>
              <.usb_command tooltip="Clear Display" command="flipdot_clear" icon="eraser" />
              <.usb_command tooltip="Clear Display (Inverted)" command="flipdot_clear --invert" icon="circle-half-stroke" />
              <.usb_command tooltip="Reboot Device" command="reboot" icon="power-off" />
              <.usb_command tooltip="Start WiFi" command="wifi start" icon="signal" />
              <.usb_command tooltip="Stop WiFi" command="wifi stop" icon="ban" />
              <.usb_command tooltip="Show Tasks" command="show_tasks" icon="list" />
            </.button_group>
          </.section>
        </div>

        <%!-- Right Column --%>
        <div class="space-y-6">
          <%!-- Generators Section --%>
          <.section title="Generators">
            <.button_group>
              <.image_button tooltip="Noise" image={Bitmap.random(16, 16)} value="random" />
              <.image_button tooltip="Gradient H" image={Bitmap.gradient_h(16, 16)} value="gradient-h" />
              <.image_button tooltip="Gradient V" image={Bitmap.gradient_v(16, 16)} value="gradient-v" />
              <.image_button tooltip="Maze" image={Maze.generate_maze(17, 17)} value="maze" />
            </.button_group>
          </.section>

          <%!-- Images Section --%>
          <.section title="Images">
            <div class="overflow-x-auto pb-2">
              <.button_group>
                <.image_button :for={{name, image} <- Flipdot.Images.images()}
                               tooltip={name}
                               image={image}
                               value={name} />
              </.button_group>
            </div>
          </.section>

          <%!-- Text Generator Section --%>
          <.section title="Text Generator">
            <form phx-change="render-text" phx-submit="render-text" class="space-y-4">
              <div class="flex flex-col gap-4">
                <input
                  type="text"
                  name="text"
                  value={@text}
                  placeholder="Type some text…"
                  class="px-4 py-2 bg-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  autofocus
                  autocomplete="off"
                  phx-debounce="300"
                />
                <select
                  :if={@font_select}
                  name="font"
                  id="font-select"
                  class="px-4 py-2 bg-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
                  phx-debounce="300"
                >
                  <%= Phoenix.HTML.Form.options_for_select(@font_select, @font_name) %>
                </select>
              </div>
              <button type="submit" class="w-full px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg">
                Render Text
              </button>
            </form>
          </.section>

          <%!-- Upload Section --%>
          <.section title="Upload Bitmap">
            <div class="relative">
              <form phx-change="validate" phx-submit="upload">
                <div class="border-2 border-dashed border-gray-600 rounded-lg p-6 text-center hover:border-indigo-500 transition-colors duration-200 cursor-pointer"
                     phx-drop-target={@uploads.frame.ref}>
                  <FontAwesome.LiveView.icon name="file-arrow-up" type="solid" class="h-12 w-12 mx-auto mb-4 text-gray-400" />
                  <p class="text-gray-400">Drag and drop or click to select</p>
                  <.live_file_input upload={@uploads.frame} class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" />

                  <%= for entry <- @uploads.frame.entries do %>
                    <div class="mt-2">
                      <div class="text-sm text-gray-400">
                        <%= entry.client_name %>
                        <%= if entry.progress > 0 do %>
                          - <%= entry.progress %>%
                        <% end %>
                      </div>

                      <%= for err <- upload_errors(@uploads.frame, entry) do %>
                        <div class="text-red-500 text-sm"><%= err %></div>
                      <% end %>
                    </div>
                  <% end %>

                  <%= for err <- upload_errors(@uploads.frame) do %>
                    <div class="text-red-500 text-sm"><%= err %></div>
                  <% end %>
                </div>
              </form>
            </div>
          </.section>
        </div>
      </div>

      <%!-- Clock in bottom right --%>
      <div class="fixed bottom-4 right-4 bg-gray-800 px-4 py-2 rounded-lg shadow-lg">
        <div class="font-mono text-sm text-gray-400">
          <%= @clock %>
        </div>
      </div>
    </div>
    """
  end

  def display(assigns) do
    ~H"""
    <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
      <div id="display" class="bg-gray-900 p-4 rounded-lg">
        <div :for={y <- (@height - 1)..0//-1} id={"row-#{y}"} class="flex">
          <div
            :for={x <- 0..(@width - 1)}
            id={"cell-#{x},#{y}"}
            phx-click="pixel"
            phx-value-x={x}
            phx-value-y={y}
            class={[
              "shrink-0 w-[8px] h-[8px] flex items-center justify-around",
              "transition-all duration-200 hover:opacity-75",
              if(Map.get(@bitmap.matrix, {x, y}) == 1,
                do: "bg-[url('/images/flipdot/flipdot-pixel-on-8x8.png')] " <>
                    "@2x:bg-[url('/images/flipdot/flipdot-pixel-on-16x16.png')] " <>
                    "@3x:bg-[url('/images/flipdot/flipdot-pixel-on-24x24.png')]",
                else: "bg-[url('/images/flipdot/flipdot-pixel-off-8x8.png')] " <>
                    "@2x:bg-[url('/images/flipdot/flipdot-pixel-off-16x16.png')] " <>
                    "@3x:bg-[url('/images/flipdot/flipdot-pixel-off-24x24.png')]"
              )
            ]}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  def tool(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class={[
        "relative p-3 rounded-lg transition-colors duration-200",
        "focus:outline-none focus:ring-2 focus:ring-indigo-500",
        @mode == @self && "bg-indigo-600" || "bg-gray-700"
      ]}
      phx-click="mode"
      value={@value}
    >
      <div class={[
        "transition-colors duration-200",
        "hover:fill-yellow-300",
        @mode == @self && "fill-gray-200" || "fill-gray-200"
      ]}>
        <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-5 w-5" />
      </div>
    </button>
    """
  end

  def app(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class={[
        "relative p-3 rounded-lg transition-colors duration-200",
        "focus:outline-none focus:ring-2 focus:ring-indigo-500",
        @app == @self && "bg-indigo-600" || "bg-gray-700"
      ]}
      phx-click="app"
      value={@value}
    >
      <div class={[
        "transition-colors duration-200",
        "hover:fill-yellow-300",
        @app == @self && "fill-gray-200" || "fill-gray-200"
      ]}>
        <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-5 w-5" />
      </div>
    </button>
    """
  end

  def filter(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="relative p-3 rounded-lg bg-gray-700 transition-colors duration-200
             hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
      phx-click={@target}
    >
      <div class="fill-gray-200">
        <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-5 w-5" />
      </div>
    </button>
    """
  end

  def image_button(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="relative p-2 rounded-lg bg-gray-700 transition-colors duration-200
             hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500
             flex items-center justify-center min-w-[48px]"
      phx-click="image"
      value={@value}
    >
      <div class="h-8 w-8 flex items-center justify-center [&>svg]:fill-gray-200">
        <%= raw(Bitmap.to_svg(@image, scale: 2)) %>
      </div>
    </button>
    """
  end

  def section(assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)
    ~H"""
    <div class="bg-gray-800 p-4 rounded-lg">
      <h2 class="text-xl font-bold mb-4"><%= @title %></h2>
      <div class={@class}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def button_group(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def usb_command(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class="relative p-3 rounded-lg bg-gray-700 transition-colors duration-200
             hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
      phx-click="usb-command"
      phx-value-command={@command}
    >
      <div class="fill-gray-200">
        <FontAwesome.LiveView.icon name={@icon} type="solid" class="h-5 w-5" />
      </div>
    </button>
    """
  end
end
