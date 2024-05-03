defmodule WalletWeb.TransactionController do
  use WalletWeb, :controller

  alias Wallet.Transactions
  # alias Wallet.Wallets
  # alias Wallet.Wallet
  alias Authentication.Helper

  def deposit(conn, %{"amount" => amount}) do
    {:ok, user_id} = Helper.get_user_id_from_conn(conn)

    with {:ok, _} <- Transactions.add_to_wallet_by_user(user_id, amount) do
      send_resp(conn, :ok, "Amount added successfully")
    else
      _ -> send_resp(conn, :bad_request, "Failed to add amount")
    end
  end
end
