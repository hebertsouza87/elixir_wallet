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
    IO.inspect(result, label: "result")

    ResponseHandler.handle_response(result, conn)
  end

  def transfer(_conn, %{"amount" => _amount, "to_wallet_number" => _to_wallet_number}) do
    :ok
  end
end
