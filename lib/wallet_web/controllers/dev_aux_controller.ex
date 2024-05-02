defmodule WalletWeb.DevAuxController do
  use WalletWeb, :controller
  alias Joken.Signer
  alias Joken.Jwt

  def create_token(conn, %{"user_id" => user_id}) do
    secret_key = Wallet.ConfigAgent.get_jwt_secret_key()

    jwt = Jwt.new()
    |> Jwt.with_claim("user_id", user_id)
    |> Jwt.sign(Signer.create("HS256", secret_key))

    case jwt do
      {:ok, jwt, _} ->
        conn
        |> put_status(:created)
        |> json(%{token: jwt})
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Não foi possível criar o token"})
    end
  end
end
