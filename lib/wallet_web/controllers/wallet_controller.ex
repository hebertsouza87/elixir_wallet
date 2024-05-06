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

  def swagger_definitions do
    swagger_definitions_for_create()
  end

  defp swagger_definitions_for_create do
    %{
      "/api/wallets": %{
        post: %{
          tags: ["wallet"],
          description: "Creates a new wallet",
          operationId: "WalletController.create",
          parameters: [jwt_auth_param()],
          responses: %{
            200 => %{description: "Success"}
          }
        }
      }
    }
  end

  defp jwt_auth_param do
    %{
      name: "Authorization",
      in: "header",
      description: "JWT token",
      required: true,
      type: "string"
    }
  end
end
