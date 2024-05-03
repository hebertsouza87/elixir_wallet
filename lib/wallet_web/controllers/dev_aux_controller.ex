defmodule WalletWeb.DevAuxController do
  use WalletWeb, :controller
  alias Joken.Signer
  alias Joken

  def create_token(conn, %{"user_id" => user_id}) do
    secret_key = Wallet.ConfigAgent.get_jwt_secret_key()

    signer = Signer.create("HS256", secret_key)

    claims = %{"user_id" => user_id}

    jwt = Joken.encode_and_sign(claims, signer)

    case jwt do
      {:ok, jwt, _} ->
        conn
        |> put_status(:created)
        |> json(%{token: jwt})
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Error creating token"})
    end
  end
end
