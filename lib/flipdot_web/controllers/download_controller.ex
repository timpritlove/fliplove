defmodule FlipdotWeb.DownloadController do
  use FlipdotWeb, :controller

  def download(conn, params) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("content-disposition", "attachment; filename=bitmap.txt")
    |> render("bitmap.txt", params: params)
  end
end
