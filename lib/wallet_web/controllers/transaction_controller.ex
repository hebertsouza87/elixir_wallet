defmodule WalletWeb.TransactionController do
  use WalletWeb, :controller

  alias Wallet.Transactions
  alias Authentication.Helper
  alias WalletWeb.ResponseHandler

  def deposit(conn, %{"amount" => amount}) do
    conn
    |> Helper.get_user_id_from_conn()
    |> Transactions.add_to_wallet_by_user(amount)
    |> ResponseHandler.handle_response(:created, conn)
  end

  def withdraw(conn, %{"amount" => amount}) do
    conn
    |> Helper.get_user_id_from_conn()
    |> Transactions.withdraw_to_wallet_by_user(amount)
    |> ResponseHandler.handle_response(:created, conn)
  end

  def transfer(conn, %{"amount" => amount, "to_wallet_number" => to_wallet_number}) do
    conn
    |> Helper.get_user_id_from_conn()
    |> Transactions.transfer_to_wallet_by_user(to_wallet_number, amount)
    |> ResponseHandler.handle_response(:created, conn)
  end
end
