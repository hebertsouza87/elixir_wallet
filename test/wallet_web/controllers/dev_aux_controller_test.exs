defmodule WalletWeb.DevAuxControllerTest do
  use WalletWeb.ConnCase
  import WalletWeb.Endpoint, warn: false

  setup do
    user_id = "d02f68d3-079b-4f5b-93ac-2628d0b624fb"
    {:ok, user_id: user_id}
  end

  test "creates a valid JWT token", %{conn: conn, user_id: user_id} do
    conn = conn
           |> post("/api/dev/token", %{"user_id" => user_id})

    assert json_response(conn, 201)["token"] != nil
  end
end
