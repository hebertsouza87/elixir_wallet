defmodule WalletWeb.WalletController do
  use WalletWeb, :controller

  alias Authentication.Helper
  alias Wallet.Wallets
  alias WalletWeb.ResponseHandler

  def create(conn, _params) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Wallets.create_wallet(%{user_id: user_id})
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end
end
