defmodule WalletWeb.WalletController do
  use WalletWeb, :controller

  alias Wallet.Wallets
  alias Wallet.Wallet
  alias Wallet.Authenticator

  def create(conn, _params) do
    IO.inspect(conn, label: "conn")
    with {:ok, user_id} <- Authenticator.get_user_id_from_conn(conn),
         {:ok, %Wallet{} = wallet} <- Wallets.create_wallet(%{user_id: user_id}) do
      conn
      |> put_status(:created)
      |> json(%{wallet: wallet})
    else
      _ -> send_resp(conn, :bad_request, "")
    end
  end
end
