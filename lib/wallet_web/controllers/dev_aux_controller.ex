defmodule WalletWeb.DevAuxController do
  use WalletWeb, :controller

  alias Authentication.Helper

  def create_token(conn, %{"user_id" => user_id}) do
    jwt = Helper.create_token(user_id)

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
