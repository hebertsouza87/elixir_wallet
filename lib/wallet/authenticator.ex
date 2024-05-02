defmodule Wallet.Authenticator do
  alias Joken.Signer
  alias Joken.Config
  alias Joken.Claim
  alias Wallet.ConfigAgent

  def get_user_id_from_conn(conn) do
    secret_key = ConfigAgent.get_jwt_secret_key()

    [auth_header | _] = Plug.Conn.get_req_header(conn, "authorization")

    [_, jwt | _] = String.split(auth_header)

    secret_key = ConfigAgent.get_jwt_secret_key()
    signer = Signer.create("HS256", secret_key)

    {:ok, claims} = jwt |> Joken.peek_claims() |> Joken.with_signer(signer) |> Joken.verify()

    user_id = claims |> Map.get("user_id")

    {:ok, user_id}
  end
end
