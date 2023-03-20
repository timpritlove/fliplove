defmodule FlipdotWeb.DownloadController do
  use FlipdotWeb, :controller
  alias Flipdot.DisplayState

  def download(conn, _params) do
    bitmap_text = DisplayState.get() |> Bitmap.to_text()

    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("content-disposition", "attachment; filename=bitmap.txt")
    |> text(bitmap_text)
  end
end
