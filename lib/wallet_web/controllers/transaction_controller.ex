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

  # def withdraw(conn, %{"amount" => amount}) do
  #   user_id = Helper.get_user_id_from_conn(conn)

  #   with {:ok, %Wallet{} = wallet} <- Wallets.get_wallet(user_id),
  #        {:ok, _} <- Transactions.withdraw_from_wallet(wallet, amount) do
  #     send_resp(conn, :ok, "Amount withdrawn successfully")
  #   else
  #     _ -> send_resp(conn, :bad_request, "Failed to withdraw amount")
  #   end
  # end

  # def transfer(conn, %{"amount" => amount, "to_wallet_number" => to_wallet_number}) do
  #   from_user_id = Helper.get_user_id_from_conn(conn)

  #   with {:ok, %Wallet{} = from_wallet} <- Wallets.get_wallet(from_user_id),
  #        {:ok, %Wallet{} = to_wallet} <- Wallets.get_wallet_by_number(to_wallet_number),
  #        {:ok, _} <- Transactions.transfer(from_wallet, to_wallet, amount) do
  #     send_resp(conn, :ok, "Amount transferred successfully")
  #   else
  #     _ -> send_resp(conn, :bad_request, "Failed to transfer amount")
  #   end
  # end
end
