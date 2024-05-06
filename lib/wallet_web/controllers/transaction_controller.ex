defmodule WalletWeb.TransactionController do
  use WalletWeb, :controller

  alias Wallet.Transactions
  alias Authentication.Helper
  alias WalletWeb.ResponseHandler

  def deposit(conn, %{"amount" => amount}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.add_to_wallet_by_user(user_id, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end

  def withdraw(conn, %{"amount" => amount}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.withdraw_to_wallet_by_user(user_id, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end

  def transfer(conn, %{"amount" => amount, "to_wallet_number" => to_wallet_number}) do
    result = case Helper.get_user_id_from_conn(conn) do
      {:ok, user_id} -> Transactions.transfer_to_wallet_by_user(user_id, to_wallet_number, amount)
      error -> error
    end

    ResponseHandler.handle_response(result, conn)
  end

  def swagger_definitions(action) do
    case action do
      :deposit -> swagger_definitions_for_deposit()
      :withdraw -> swagger_definitions_for_withdraw()
      :transfer -> swagger_definitions_for_transfer()
    end
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

  defp swagger_definitions_for_deposit do
    %{
      "/api/deposit": %{
        post: %{
          tags: ["transaction"],
          description: "Deposits an amount to the user's wallet",
          operationId: "TransactionController.deposit",
          parameters: [
            jwt_auth_param(),
            %{
              name: "body",
              in: "body",
              required: true,
              schema: %{
                type: "object",
                properties: %{
                  "amount" => %{type: "number", format: "float"}
                }
              }
            }
          ],
          responses: %{
            200 => %{description: "Success"}
          }
        }
      }
    }
  end

  defp swagger_definitions_for_withdraw do
    %{
      "/api/deposit": %{
        post: %{
          tags: ["transaction"],
          description: "Withdraw an amount to the user's wallet",
          operationId: "TransactionController.withdraw",
          parameters: [
            jwt_auth_param(),
            %{
              name: "body",
              in: "body",
              required: true,
              schema: %{
                type: "object",
                properties: %{
                  "amount" => %{type: "number", format: "float"}
                }
              }
            }
          ],
          responses: %{
            200 => %{description: "Success"}
          }
        }
      }
    }
  end

  defp swagger_definitions_for_transfer do
    %{
      "/api/deposit": %{
        post: %{
          tags: ["transaction"],
          description: "Transfer an amount to the user's wallet",
          operationId: "TransactionController.transfer",
          parameters: [
            jwt_auth_param(),
            %{
              name: "body",
              in: "body",
              required: true,
              schema: %{
                type: "object",
                properties: %{
                  "amount" => %{type: "number", format: "float"},
                  "to_wallet_number" => %{type: "string"}
                }
              }
            }
          ],
          responses: %{
            200 => %{description: "Success"}
          }
        }
      }
    }
  end
end
