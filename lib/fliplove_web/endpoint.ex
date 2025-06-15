defmodule FliploveWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :fliplove
  require Logger

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_fliplove_key",
    signing_salt: "lWszlqYC",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :fliplove,
    gzip: false,
    only: FliploveWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug FliploveWeb.Router

  @impl true
  def init(_key, config) do
    http_config = Keyword.get(config, :http)
    https_config = Keyword.get(config, :https)

    if http_config do
      port = Keyword.get(http_config, :port, "unknown")
      Logger.info("[FliploveWeb.Endpoint] HTTP enabled on port #{port}")
    end

    if https_config do
      port = Keyword.get(https_config, :port, "unknown")
      keyfile = Keyword.get(https_config, :keyfile, "not set")
      certfile = Keyword.get(https_config, :certfile, "not set")
      Logger.info("[FliploveWeb.Endpoint] HTTPS enabled on port #{port} (keyfile: #{keyfile}, certfile: #{certfile})")
    else
      Logger.info("[FliploveWeb.Endpoint] HTTPS is not enabled.")
    end

    {:ok, config}
  end
end
