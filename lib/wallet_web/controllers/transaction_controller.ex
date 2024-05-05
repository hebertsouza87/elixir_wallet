defmodule WalletWeb.TransactionController do
  use WalletWeb, :controller

  alias Wallet.Transactions
  alias Authentication.Helper
  alias WalletWeb.ResponseHandler

  def deposit(conn, %{"amount" => amount}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.add_to_wallet_by_user(user_id, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end

  def withdraw(conn, %{"amount" => amount}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.withdraw_to_wallet_by_user(user_id, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end

  def transfer(conn, %{"amount" => amount, "to_wallet_number" => to_wallet_number}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.transfer_to_wallet_by_user(user_id, to_wallet_number, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end
end
