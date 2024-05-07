defmodule WalletWeb.WalletController do
  use WalletWeb, :controller

  alias Authentication.Helper
  alias Wallet.Wallets
  alias WalletWeb.ResponseHandler

  def create(conn, _params) do
    conn
    |> Helper.get_user_id_from_conn()
    |> Wallets.create_wallet()
    |> ResponseHandler.handle_response(conn, :created)
  end
end
