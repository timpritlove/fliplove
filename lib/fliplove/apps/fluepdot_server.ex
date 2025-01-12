defmodule Fliplove.Apps.FluepdotServer do
  @moduledoc """
  Simulates a Fluepdot display server that receives bitmap updates via UDP and HTTP.
  """
  use Fliplove.Apps.Base
  alias Fliplove.{Bitmap, Display}
  require Logger

  @port_env "FLIPLOVE_PORT"
  @port_default 1337
  @http_port 80

  def init_app(_opts) do
    udp_port =
      case System.get_env(@port_env) do
        nil -> @port_default
        port -> String.to_integer(port)
      end

    # Clear display on startup
    Display.clear()

    # Start UDP server
    {:ok, udp_socket} = :gen_udp.open(udp_port, [:binary, active: true])
    Logger.info("Fluepdot Server listening on UDP port #{udp_port}")

    # Start HTTP server
    {:ok, http_pid} =
      Bandit.start_link(
        plug: Fliplove.Apps.FluepdotServer.HttpHandler,
        port: @http_port,
        scheme: :http
      )

    Logger.info("Fluepdot Server listening on HTTP port #{@http_port}")

    state = %{
      udp_socket: udp_socket,
      http_pid: http_pid,
      rendering_mode: :differential
    }

    {:ok, state}
  end

  @impl true
  def handle_info({:udp, _socket, _address, _port, data}, state) do
    Logger.debug("Received UDP packet")

    # Convert binary data to bitmap and update display
    data
    |> Bitmap.from_binary(Display.width(), Display.height())
    |> Display.set()

    {:noreply, state}
  end

  @impl Fliplove.Apps.Base
  def cleanup_app(_reason, %{udp_socket: socket, http_pid: http_pid}) do
    Logger.info("Fluepdot Server has been shut down.")
    if socket, do: :gen_udp.close(socket)
    if http_pid, do: Process.exit(http_pid, :normal)
    :ok
  end

  @doc """
  Sends a bitmap to a Fluepdot display server via UDP.
  Returns :ok on success or {:error, reason} on failure.
  """
  def send_bitmap(bitmap, host, port \\ @port_default) do
    with {:ok, socket} <- :gen_udp.open(0, [:binary]),
         binary_data <- Bitmap.to_binary(bitmap),
         :ok <- :gen_udp.send(socket, String.to_charlist(host), port, binary_data) do
      :gen_udp.close(socket)
      :ok
    else
      {:error, reason} = error ->
        Logger.error("Failed to send bitmap: #{inspect(reason)}")
        error
    end
  end

  @doc """
  Gets the current rendering mode.
  """
  def get_rendering_mode do
    GenServer.call(__MODULE__, :get_rendering_mode)
  end

  @doc """
  Sets the rendering mode to either :full or :differential.
  """
  def set_rendering_mode(mode) when mode in [:full, :differential] do
    GenServer.call(__MODULE__, {:set_rendering_mode, mode})
  end

  @impl true
  def handle_call(:get_rendering_mode, _from, state) do
    mode = Map.get(state, :rendering_mode, :differential)
    Logger.debug("Getting rendering mode: #{mode}")
    {:reply, mode, Map.put(state, :rendering_mode, mode)}
  end

  @impl true
  def handle_call({:set_rendering_mode, mode}, _from, state) do
    Logger.debug("Setting rendering mode to: #{mode}")
    {:reply, :ok, Map.put(state, :rendering_mode, mode)}
  end
end

defmodule Fliplove.Apps.FluepdotServer.HttpHandler do
  @moduledoc """
  HTTP handler for the Fluepdot server using Plug.
  """
  use Plug.Router
  alias Fliplove.{Bitmap, Display}
  require Logger

  plug :log_request
  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["*/*"]

  plug :dispatch

  defp log_request(conn, _opts) do
    query_string = if conn.query_string != "", do: "?#{conn.query_string}", else: ""
    Logger.info("HTTP #{conn.method} #{conn.request_path}#{query_string}")
    conn
  end

  get "/framebuffer" do
    bitmap = Display.get()
    text = Bitmap.to_text(bitmap, on: ?X, off: ?\s)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, text)
  end

  post "/framebuffer" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    case parse_and_display_bitmap(body) do
      :ok ->
        send_resp(conn, 200, "OK")

      {:error, reason} ->
        Logger.error("Failed to parse bitmap: #{inspect(reason)}")
        send_resp(conn, 400, "Bad Request: #{inspect(reason)}")
    end
  end

  get "/pixel" do
    with {:ok, x, y} <- validate_coordinates(conn.query_params),
         bitmap <- Display.get(),
         value <- Bitmap.get_pixel(bitmap, {x, y}) do
      text = if value == 1, do: "X", else: " "

      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, text)
    else
      {:error, reason} ->
        send_resp(conn, 400, "Bad Request: #{reason}")
    end
  end

  post "/pixel" do
    with {:ok, x, y} <- validate_coordinates(conn.query_params) do
      bitmap = Display.get()
      new_bitmap = Bitmap.set_pixel(bitmap, {x, y}, 1)
      Display.set(new_bitmap)
      send_resp(conn, 200, "OK")
    else
      {:error, reason} ->
        send_resp(conn, 400, "Bad Request: #{reason}")
    end
  end

  delete "/pixel" do
    with {:ok, x, y} <- validate_coordinates(conn.query_params) do
      bitmap = Display.get()
      new_bitmap = Bitmap.set_pixel(bitmap, {x, y}, 0)
      Display.set(new_bitmap)
      send_resp(conn, 200, "OK")
    else
      {:error, reason} ->
        send_resp(conn, 400, "Bad Request: #{reason}")
    end
  end

  get "/fonts" do
    fonts = Fliplove.Font.Library.get_fonts()

    text =
      fonts
      |> Enum.map(fn font ->
        "#{font.name}\n#{font.properties.family_name}\n"
      end)
      |> Enum.join("")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, text)
  end

  post "/framebuffer/text" do
    with {:ok, x, y, font_name} <- validate_text_params(conn.query_params),
         :ok <- validate_content_type(conn),
         {:ok, text, conn} <- Plug.Conn.read_body(conn),
         :ok <- validate_text_content(text) do
      font = Fliplove.Font.Library.get_font_by_name(font_name)
      mode = Fliplove.Apps.FluepdotServer.get_rendering_mode()
      Logger.debug("Rendering text in #{mode} mode")

      # In full mode, start with empty bitmap. In differential mode, use current display
      base_bitmap =
        case mode do
          :full ->
            Logger.debug("Creating empty bitmap for full mode")
            Bitmap.new(Display.width(), Display.height())

          :differential ->
            Logger.debug("Using current display for differential mode")
            Display.get()
        end

      new_bitmap =
        Fliplove.Font.Renderer.place_text(
          base_bitmap,
          font,
          text,
          align: :left,
          valign: :top,
          margin_x: x,
          margin_y: y
        )

      Display.set(new_bitmap)
      send_resp(conn, 200, "OK")
    else
      {:error, reason} ->
        send_resp(conn, 400, "Bad Request: #{reason}")
    end
  end

  get "/rendering/mode" do
    mode = Fliplove.Apps.FluepdotServer.get_rendering_mode()

    text =
      case mode do
        :full -> "0"
        :differential -> "1"
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, text)
  end

  put "/rendering/mode" do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn),
         :ok <- validate_content_type(conn),
         {:ok, mode} <- parse_rendering_mode(body) do
      Fliplove.Apps.FluepdotServer.set_rendering_mode(mode)
      send_resp(conn, 200, "OK")
    else
      {:error, reason} ->
        send_resp(conn, 400, "Bad Request: #{reason}")
    end
  end

  defp validate_content_type(conn) do
    case get_req_header(conn, "content-type") do
      # No content type specified is OK
      [] -> :ok
      ["text/plain"] -> :ok
      ["text/plain; charset=utf-8"] -> :ok
      [content_type] -> {:error, "Unsupported Content-Type: #{content_type}. Use text/plain or no Content-Type"}
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp parse_and_display_bitmap(body) do
    try do
      body
      |> Bitmap.from_string()
      |> Display.set()

      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp validate_coordinates(%{"x" => x_str, "y" => y_str}) do
    try do
      x = String.to_integer(x_str)
      y = String.to_integer(y_str)
      width = Display.width()
      height = Display.height()

      # Validate coordinates are within display bounds
      cond do
        x < 0 -> {:error, "X coordinate #{x} is negative"}
        x >= width -> {:error, "X coordinate #{x} is outside display width (0..#{width - 1})"}
        y < 0 -> {:error, "Y coordinate #{y} is negative"}
        y >= height -> {:error, "Y coordinate #{y} is outside display height (0..#{height - 1})"}
        true -> {:ok, x, y}
      end
    rescue
      ArgumentError -> {:error, "Invalid coordinate format"}
    end
  end

  defp validate_coordinates(_), do: {:error, "Missing x or y coordinates"}

  defp validate_text_params(%{"x" => x_str, "y" => y_str, "font" => font_name}) do
    try do
      x = String.to_integer(x_str)
      y = String.to_integer(y_str)

      # Validate coordinates are within display bounds
      if x >= 0 and x < Display.width() and y >= 0 and y < Display.height() do
        {:ok, x, y, font_name}
      else
        {:error, "Coordinates out of bounds"}
      end
    rescue
      ArgumentError -> {:error, "Invalid coordinate format"}
    end
  end

  defp validate_text_params(_), do: {:error, "Missing required parameters: x, y, font"}

  defp validate_text_content(""), do: {:error, "Text content cannot be empty"}
  defp validate_text_content(nil), do: {:error, "Text content cannot be empty"}
  defp validate_text_content(_text), do: :ok

  defp parse_rendering_mode("0"), do: {:ok, :full}
  defp parse_rendering_mode("1"), do: {:ok, :differential}

  defp parse_rendering_mode(value),
    do: {:error, "Invalid rendering mode: #{value}. Use 0 for full or 1 for differential"}
end
