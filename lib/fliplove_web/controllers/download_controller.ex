defmodule FliploveWeb.DownloadController do
  use FliploveWeb, :controller
  alias Fliplove.Bitmap
  alias Fliplove.Display

  def download(conn, _params) do
    bitmap_text = Display.get() |> Bitmap.to_text()

    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("content-disposition", "attachment; filename=bitmap.txt")
    |> text(bitmap_text)
  end
end
