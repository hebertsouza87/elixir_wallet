defmodule WalletWeb.SwaggerSpec do
  use PhoenixSwagger

  @moduledoc """
  Swagger specifications for Wallet API.
  """

  @doc """
  Creates the Swagger specifications for the Wallet API.
  """
  def spec do
    swagger = %{
      swagger: "2.0",
      info: %{
        version: "1.0",
        title: "Wallet API",
        description: "API for managing wallet transactions"
      },
      paths: paths()
    }
    PhoenixSwagger.swagger_schema(swagger)
  end

  defp paths do
    Map.merge(
      WalletWeb.WalletController.swagger_definitions(),
      WalletWeb.TransactionController.swagger_definitions(:deposit),
      WalletWeb.TransactionController.swagger_definitions(:withdraw),
      WalletWeb.TransactionController.swagger_definitions(:transfer)
    )
  end
end
