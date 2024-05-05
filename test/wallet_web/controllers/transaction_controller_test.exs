defmodule WalletWeb.TransactionControllerTest do
  import Wallet.Factory

  use WalletWeb.ConnCase

  alias Wallet.Transactions
  alias Wallet.Wallet

  setup do
    wallet1 = insert(:wallet)

    {:ok, token, _} = Authentication.Helper.create_token(wallet1.user_id)

    {:ok, conn: build_conn(), token: token}
  end

    test "returns 200 on successful deposit", %{conn: conn, token: token} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/deposit", %{"amount" => 100.0})

      assert json_response(conn, 200)
    end

  end
