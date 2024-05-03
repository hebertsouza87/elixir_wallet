defmodule Authentication.HelperTest do
  use ExUnit.Case
  alias Authentication.Helper
  alias Joken.Signer
  alias Plug.Conn

  setup do
    :ok
  end

  test "get_user_id_from_conn/1 returns user_id from conn" do
    user_id = "test_user_id"
    token = Helper.create_token(user_id)
    conn = %Conn{req_headers: [{"authorization", "Bearer #{token}"}]}

    assert {:ok, ^user_id} = Helper.get_user_id_from_conn(conn)
  end

  test "create_token/1 returns a valid token" do
    user_id = "test_user_id"
    token = Helper.create_token(user_id)

    secret_key = Wallet.ConfigAgent.get_jwt_secret_key()
    signer = Signer.create("HS256", secret_key)
    {:ok, claims} = Joken.verify(token, signer, [])

    assert claims["user_id"] == user_id
  end
end