defmodule Authentication.Helper do
  alias Joken
  alias Joken.Signer
  alias Wallet.ConfigAgent

  def get_user_id_from_conn(conn) do
    secret_key = ConfigAgent.get_jwt_secret_key()

    [auth_header | _] = Plug.Conn.get_req_header(conn, "authorization")

    [_, jwt | _] = String.split(auth_header)

    signer = Signer.create("HS256", secret_key)

    {:ok, claims} = jwt |> Joken.verify(signer, [])

    user_id = claims |> Map.get("user_id")

    {:ok, user_id}
  end

  def create_token(user_id) do
    secret_key = Wallet.ConfigAgent.get_jwt_secret_key()

    signer = Signer.create("HS256", secret_key)

    claims = %{"user_id" => user_id}

    Joken.encode_and_sign(claims, signer)
  end
end
