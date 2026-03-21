defmodule FliploveWeb.Plugs.BrowserIconSink do
  @moduledoc false

  import Plug.Conn

  # Safari / iOS and some clients probe these on every visit; we do not ship icons at these URLs.
  @paths MapSet.new([
    "/apple-touch-icon.png",
    "/apple-touch-icon-precomposed.png"
  ])

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method in ["GET", "HEAD"] and MapSet.member?(@paths, conn.request_path) do
      # Halt before Plug.Telemetry so Phoenix.Logger does not emit GET/Sent lines for these probes.
      conn |> send_resp(204, "") |> halt()
    else
      conn
    end
  end
end
