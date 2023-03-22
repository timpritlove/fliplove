defmodule FlipdotWeb.PageControllerTest do
  use FlipdotWeb.ConnCase

  test "GET /hello", %{conn: conn} do
    conn = get(conn, ~p"/hello")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
