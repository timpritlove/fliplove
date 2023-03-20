defmodule FlipdotWeb.FluepdotController do
  use FlipdotWeb, :controller

  def rendering_mode(conn, params) do
    mode =
      cond do
        params["1"] != nil -> :update_diff
        params["0"] != nil -> :update_complete
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Mode Set to #{mode}\n")
  end
end
