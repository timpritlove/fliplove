defmodule FliploveWeb.FliploveLive do
  use FliploveWeb, :live_view
  alias Fliplove.Bitmap
  alias Fliplove.Bitmap.GameOfLife
  alias Fliplove.Bitmap.Generator
  alias Fliplove.Bitmap.Maze
  alias Fliplove.Display
  alias Fliplove.Font.Library
  alias Fliplove.Font.Renderer
  alias FliploveWeb.VirtualDisplay
  import FliploveWeb.VirtualDisplayComponent
  import FliploveWeb.CoreComponents

  require Logger
  require Integer

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(250, self(), :tick)
      Phoenix.PubSub.subscribe(Fliplove.PubSub, Display.topic())
      Phoenix.PubSub.subscribe(Fliplove.PubSub, Library.topic())
      Phoenix.PubSub.subscribe(Fliplove.PubSub, Fliplove.TelegramBot.topic())
      VirtualDisplay.subscribe()
    end

    # Get images that match display dimensions
    display_images =
      Fliplove.Images.images()
      |> Enum.filter(fn {_name, bitmap} ->
        bitmap.width == Display.width() && bitmap.height == Display.height()
      end)
      |> Map.new()

    initial_bitmap = Display.get()
    VirtualDisplay.update_bitmap(initial_bitmap)

    socket =
      socket
      |> assign(page_title: "Fliplove")
      |> assign(:bitmap, initial_bitmap)
      |> assign(:virtual_bitmap, initial_bitmap)
      |> assign(:clock, clock())
      |> assign(:app, Fliplove.Apps.running_app())
      |> assign(:text, "")
      |> assign(:font_name, "flipdot")
      |> assign(:mode, :pencil)
      |> assign(:prev_xy, nil)
      |> assign(:font_select, Library.get_fonts() |> build_font_select())
      |> assign(:usb_mode?, System.get_env("FLIPLOVE_DRIVER") == "FLUEPDOT_USB")
      |> assign(:display_images, display_images)
      |> assign(:delay_enabled, VirtualDisplay.get_delay_enabled())
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

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_info({:display_updated, bitmap}, socket) do
    VirtualDisplay.update_bitmap(bitmap)
    {:noreply, assign(socket, :bitmap, bitmap)}
  end

  @impl Phoenix.LiveView
  def handle_info({:bitmap, bitmap}, socket) do
    {:noreply, assign(socket, :bitmap, bitmap)}
  end

  @impl Phoenix.LiveView
  def handle_info({:running_app, app}, socket) do
    {:noreply,
     socket
     |> assign(:app, app)}
  end

  @impl Phoenix.LiveView
  def handle_info(:font_library_update, socket) do
    fonts = Library.get_fonts()
    font_select = build_font_select(fonts)

    font_name =
      if Enum.any?(fonts, &(&1.name == socket.assigns.font_name)),
        do: socket.assigns.font_name,
        else: "flipdot"

    {:noreply,
     socket
     |> assign(:font_select, font_select)
     |> assign(:font_name, font_name)}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:clock, clock())
     |> assign(:app, Fliplove.Apps.running_app())}
  end

  @impl Phoenix.LiveView
  def handle_info({:virtual_display_updated, bitmap}, socket) do
    {:noreply, assign(socket, :virtual_bitmap, bitmap)}
  end

  @impl Phoenix.LiveView
  def handle_event("translate-up", _params, socket) do
    Display.get() |> Bitmap.translate({0, 1}) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("translate-down", _params, socket) do
    Display.get() |> Bitmap.translate({0, -1}) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("translate-right", _params, socket) do
    Display.get() |> Bitmap.translate({1, 0}) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("translate-left", _params, socket) do
    Display.get() |> Bitmap.translate({-1, 0}) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("flip-horizontally", _params, socket) do
    Display.get() |> Bitmap.flip_horizontally() |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("flip-vertically", _params, socket) do
    Display.get() |> Bitmap.flip_vertically() |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("invert", _params, socket) do
    Display.get() |> Bitmap.invert() |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("random", _params, socket) do
    Generator.random(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("game-of-life", _params, socket) do
    Display.get() |> GameOfLife.game_of_life() |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("gradient-h", _params, socket) do
    Generator.gradient_h(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("gradient-v", _params, socket) do
    Generator.gradient_v(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("app", params, socket) do
    app = String.to_atom(params["value"])

    if app == Fliplove.Apps.running_app() do
      Fliplove.Apps.stop_app()
    else
      Fliplove.Apps.start_app(app)
    end

    socket = socket |> assign(:app, Fliplove.Apps.running_app())
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => ""}, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "random"}, socket) do
    Generator.random(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "perlin"}, socket) do
    Generator.random_perlin_noise(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "flow-field"}, socket) do
    Generator.flow_field(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "wave-interference"}, socket) do
    Generator.wave_interference(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "recursive-subdivision"}, socket) do
    Generator.recursive_subdivision(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "mandelbrot"}, socket) do
    Generator.mandelbrot(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "gradient-h"}, socket) do
    Generator.gradient_h(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "gradient-v"}, socket) do
    Generator.gradient_v(Display.width(), Display.height()) |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "maze"}, socket) do
    display_width = Display.width()
    display_height = Display.height()
    maze_width = if Integer.is_odd(display_width), do: display_width, else: display_width - 1
    maze_height = if Integer.is_odd(display_height), do: display_height, else: display_height - 1

    Maze.generate_maze(maze_width, maze_height)
    |> Bitmap.crop_relative(display_width, display_height, rel_y: :top)
    |> Display.set()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => "game-of-life"}, socket) do
    Display.get() |> GameOfLife.game_of_life() |> Display.set()
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("image", %{"value" => image}, socket) do
    if bitmap = socket.assigns.display_images[image] do
      Display.set(bitmap)
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("erase", _params, socket) do
    Bitmap.new(Display.width(), Display.height()) |> Display.set()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("usb-command", %{"command" => command}, socket) do
    GenServer.cast(Fliplove.Driver.FluepdotUsb, {:command, command})
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("update_component", %{"module" => module, "id" => id}, socket) do
    module = String.to_existing_atom(module)
    send_update(module, id: id, process_next_column: true)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-delay", params, socket) do
    # When checkbox is checked, we get the value. When unchecked, the param is not present
    enabled = Map.has_key?(params, "delay-enabled")
    VirtualDisplay.set_delay_enabled(enabled)
    {:noreply, assign(socket, :delay_enabled, enabled)}
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
      display_name =
        [
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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gray-900 text-gray-100">
        <div class="max-w-7xl mx-auto">
          <div class="flex justify-between items-center mb-8">
            <h1 class="text-3xl font-bold">Fliplove</h1>
            <div class="flex items-center gap-4">
              <div class="flex items-center gap-2">
                <form phx-change="toggle-delay" class="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="delay-enabled"
                    name="delay-enabled"
                    checked={@delay_enabled}
                    class="w-4 h-4 text-indigo-600 bg-gray-700 border-gray-600 rounded focus:ring-indigo-500"
                    value="true"
                  />
                  <label for="delay-enabled" class="text-sm text-gray-300">Enable Delay</label>
                </form>
              </div>
              <button
                phx-click="download"
                class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg flex items-center gap-2"
              >
                <.icon name="hero-arrow-down-tray" class="h-5 w-5" />
                <span>Download Display</span>
              </button>
            </div>
          </div>

          <div class="flex flex-col items-center mb-8">
            <.display bitmap={@virtual_bitmap} width={Display.width()} height={Display.height()} />
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
                  <.app app={@app} tooltip="Fluepdot Server" value="fluepdot_server" self={:fluepdot_server} icon="server" />
                  <.app app={@app} tooltip="Date & Time" value="datetime" self={:datetime} icon="clock" />
                  <.app app={@app} tooltip="Timetable" value="timetable" self={:timetable} icon="train" />
                </.button_group>
              </.section>

              <%!-- USB Commands Section --%>
              <.section :if={@usb_mode?} title="USB Commands">
                <.button_group>
                  <.usb_command tooltip="Clear Display" command="flipdot_clear" icon="eraser" />
                  <.usb_command
                    tooltip="Clear Display (Inverted)"
                    command="flipdot_clear --invert"
                    icon="circle-half-stroke"
                  />
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
                  <.image_button tooltip="Noise" image={Generator.random(Display.width(), Display.height())} value="random" />
                  <.image_button
                    tooltip="Perlin Noise"
                    image={Generator.random_perlin_noise(Display.width(), Display.height())}
                    value="perlin"
                  />
                  <.image_button
                    tooltip="Flow Field"
                    image={Generator.flow_field(Display.width(), Display.height())}
                    value="flow-field"
                  />
                  <.image_button
                    tooltip="Wave Interference"
                    image={Generator.wave_interference(Display.width(), Display.height())}
                    value="wave-interference"
                  />
                  <.image_button
                    tooltip="Recursive Subdivision"
                    image={Generator.recursive_subdivision(Display.width(), Display.height())}
                    value="recursive-subdivision"
                  />
                  <.image_button
                    tooltip="Mandelbrot"
                    image={Generator.mandelbrot(Display.width(), Display.height())}
                    value="mandelbrot"
                  />
                  <.image_button
                    tooltip="Gradient H"
                    image={Generator.gradient_h(Display.width(), Display.height())}
                    value="gradient-h"
                  />
                  <.image_button
                    tooltip="Gradient V"
                    image={Generator.gradient_v(Display.width(), Display.height())}
                    value="gradient-v"
                  />
                  <.image_button
                    tooltip="Maze"
                    image={
                      Maze.generate_maze(
                        if(Integer.is_odd(Display.width()), do: Display.width(), else: Display.width() - 1),
                        if(Integer.is_odd(Display.height()), do: Display.height(), else: Display.height() - 1)
                      )
                    }
                    value="maze"
                  />
                </.button_group>
              </.section>

              <%!-- Images Section --%>
              <.section title="Images">
                <div class="overflow-x-auto pb-2">
                  <.button_group>
                    <.image_button :for={{name, image} <- @display_images} tooltip={name} image={image} value={name} />
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
                      {Phoenix.HTML.Form.options_for_select(@font_select, @font_name)}
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
                    <div
                      class="border-2 border-dashed border-gray-600 rounded-lg p-6 text-center hover:border-indigo-500 transition-colors duration-200 cursor-pointer"
                      phx-drop-target={@uploads.frame.ref}
                    >
                      <.icon name="hero-arrow-up-tray" class="h-12 w-12 mx-auto mb-4 text-gray-400" />
                      <p class="text-gray-400">Drag and drop or click to select</p>
                      <.live_file_input
                        upload={@uploads.frame}
                        class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      />

                      <div :for={entry <- @uploads.frame.entries} class="mt-2">
                        <div class="text-sm text-gray-400">
                          {entry.client_name}
                          <span :if={entry.progress > 0}>
                            - {entry.progress}%
                          </span>
                        </div>

                        <div :for={err <- upload_errors(@uploads.frame, entry)} class="text-red-500 text-sm">{err}</div>
                      </div>

                      <div :for={err <- upload_errors(@uploads.frame)} class="text-red-500 text-sm">{err}</div>
                    </div>
                  </form>
                </div>
              </.section>
            </div>
          </div>

          <%!-- Clock in bottom right --%>
          <div class="fixed bottom-4 right-4 bg-gray-800 px-4 py-2 rounded-lg shadow-lg">
            <div class="font-mono text-sm text-gray-400">
              {@clock}
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def tool(assigns) do
    ~H"""
    <button
      title={@tooltip}
      class={[
        "relative p-3 rounded-lg transition-colors duration-200",
        "focus:outline-none focus:ring-2 focus:ring-indigo-500",
        (@mode == @self && "bg-indigo-600") || "bg-gray-700"
      ]}
      phx-click="mode"
      value={@value}
    >
      <div class={[
        "transition-colors duration-200",
        "hover:text-yellow-300",
        (@mode == @self && "text-gray-200") || "text-gray-200"
      ]}>
        <.icon :if={@icon == "pencil"} name="hero-pencil" class="h-5 w-5" />
        <.icon :if={@icon == "fill"} name="hero-paint-brush" class="h-5 w-5" />
        <.icon :if={@icon == "draw-polygon"} name="hero-squares-2x2" class="h-5 w-5" />
        <.icon :if={@icon == "vector-square"} name="hero-square-3-stack-3d" class="h-5 w-5" />
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
        (@app == @self && "bg-indigo-600") || "bg-gray-700"
      ]}
      phx-click="app"
      value={@value}
    >
      <div class={[
        "transition-colors duration-200",
        "hover:text-yellow-300",
        (@app == @self && "text-gray-200") || "text-gray-200"
      ]}>
        <.icon :if={@icon == "gauge-high"} name="hero-chart-bar" class="h-5 w-5" />
        <.icon :if={@icon == "images"} name="hero-squares-2x2" class="h-5 w-5" />
        <.icon :if={@icon == "hat-wizard"} name="hero-sparkles" class="h-5 w-5" />
        <.icon :if={@icon == "icons"} name="hero-squares-plus" class="h-5 w-5" />
        <.icon :if={@icon == "server"} name="hero-server" class="h-5 w-5" />
        <.icon :if={@icon == "clock"} name="hero-clock" class="h-5 w-5" />
        <.icon :if={@icon == "train"} name="hero-truck" class="h-5 w-5" />
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
      <div class="text-gray-200">
        <.icon :if={@icon == "arrow-up"} name="hero-arrow-up" class="h-5 w-5" />
        <.icon :if={@icon == "arrow-down"} name="hero-arrow-down" class="h-5 w-5" />
        <.icon :if={@icon == "arrow-left"} name="hero-arrow-left" class="h-5 w-5" />
        <.icon :if={@icon == "arrow-right"} name="hero-arrow-right" class="h-5 w-5" />
        <.icon :if={@icon == "arrow-down-up-across-line"} name="hero-arrows-up-down" class="h-5 w-5" />
        <.icon :if={@icon == "arrow-right-arrow-left"} name="hero-arrows-right-left" class="h-5 w-5" />
        <.icon :if={@icon == "image"} name="hero-photo" class="h-5 w-5" />
        <.icon :if={@icon == "eraser"} name="hero-backspace" class="h-5 w-5" />
        <.icon :if={@icon == "chess-board"} name="hero-squares-2x2" class="h-5 w-5" />
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
             flex items-center justify-center min-w-[96px]"
      phx-click="image"
      value={@value}
    >
      <div class="h-16 w-32 flex items-center justify-center [&>svg]:fill-gray-200">
        {raw(Bitmap.to_svg(@image, scale: 2))}
      </div>
    </button>
    """
  end

  def section(assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <div class="bg-gray-800 p-4 rounded-lg">
      <h2 class="text-xl font-bold mb-4">{@title}</h2>
      <div class={@class}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  def button_group(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2">
      {render_slot(@inner_block)}
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
      <div class="text-gray-200">
        <.icon :if={@icon == "eraser"} name="hero-backspace" class="h-5 w-5" />
        <.icon :if={@icon == "circle-half-stroke"} name="hero-adjustments-horizontal" class="h-5 w-5" />
        <.icon :if={@icon == "power-off"} name="hero-power" class="h-5 w-5" />
        <.icon :if={@icon == "signal"} name="hero-signal" class="h-5 w-5" />
        <.icon :if={@icon == "ban"} name="hero-no-symbol" class="h-5 w-5" />
        <.icon :if={@icon == "list"} name="hero-list-bullet" class="h-5 w-5" />
      </div>
    </button>
    """
  end
end
