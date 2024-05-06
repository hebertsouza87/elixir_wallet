defmodule WalletWeb.TransactionControllerTest do
  import Wallet.Factory

  use WalletWeb.ConnCase

  setup do
    wallet1 = insert(:wallet)
    wallet2 = insert(:wallet)

    {:ok, token, _} = Authentication.Helper.create_token(wallet1.user_id)

    {:ok, conn: build_conn(), token: token, wallet1: wallet1, wallet2: wallet2}
  end

  test "returns 200 on successful deposit", %{conn: conn, token: token} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/deposit", %{"amount" => 100.0})

    assert json_response(conn, 200)["id"] != nil

  end

  test "returns 200 on successful withdraw", %{conn: conn, token: token} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/withdraw", %{"amount" => 100.0})

    assert json_response(conn, 200)["id"] != nil
  end

  test "returns 400 on insuficient funds", %{conn: conn, token: token} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/withdraw", %{"amount" => 100.01})

    assert json_response(conn, 400)
  end

  test "returns 400 on invalid amount funds", %{conn: conn, token: token} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/withdraw", %{"amount" => -100.0})

    assert json_response(conn, 400)
  end


  test "returns 400 on not found user", %{conn: conn} do
    {:ok, token, _} = Authentication.Helper.create_token(Ecto.UUID.generate())

    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/withdraw", %{"amount" => -100.0})

    assert json_response(conn, 400)
  end

  test "returns 200 on successful transfer", %{conn: conn, token: token, wallet2: wallet2} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/transfer", %{"amount" => 100.0, "to_wallet_number" => wallet2.number})

    assert json_response(conn, 200)["id"] != nil
  end

  test "returns 404 on not found wallet number", %{conn: conn, token: token} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/transfer", %{"amount" => 100.0, "to_wallet_number" => 1234567})

    assert json_response(conn, 404)
  end

  test "returns 400 on insuficient found", %{conn: conn, token: token, wallet2: wallet2} do
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/transfer", %{"amount" => 100.01, "to_wallet_number" => wallet2.number})

    assert json_response(conn, 400)
  end

end
