defmodule WalletWeb.WalletControllerTest do
  use WalletWeb.ConnCase
  import WalletWeb.Endpoint, warn: false

  setup do
    user_id = "d02f68d3-079b-4f5b-93ac-2628d0b624fb"
    {:ok, user_id: user_id}
  end

  test "creates a wallet with valid JWT token", %{conn: conn, user_id: user_id} do
    {:ok, token, _} = Authentication.Helper.create_token(user_id)
    conn = conn
           |> put_req_header("authorization", "Bearer #{token}")
           |> post("/api/wallets", %{})

    assert json_response(conn, 200)["id"] != nil
    assert json_response(conn, 200)["number"] != nil
    assert json_response(conn, 200)["balance"] != "0.0"
  end

  test "returns error with invalid JWT token", %{conn: conn} do
    invalid_token = "token-inválido"
    conn = conn
    |> put_req_header("authorization", "Bearer #{invalid_token}")
    |> post("/api/wallets")

    assert json_response(conn, 500)
  end
end
