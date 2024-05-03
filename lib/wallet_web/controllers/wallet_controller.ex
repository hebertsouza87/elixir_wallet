defmodule WalletWeb.WalletController do
  use WalletWeb, :controller

  alias Authentication.Helper
  alias Wallet.Wallets
  alias Wallet.Wallet
  alias WalletWeb.WalletController.WalletJSON

  def create(conn, _params) do
    with {:ok, user_id} <- Helper.get_user_id_from_conn(conn),
         {:ok, %Wallet{} = wallet} <- Wallets.create_wallet(%{user_id: user_id}) do
      json(conn, WalletJSON.render(wallet))
    else
      _ -> send_resp(conn, :bad_request, "")
    end
  end
end