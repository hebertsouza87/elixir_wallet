defmodule Wallet.Kafka.Producer do
  alias Wallet.Transaction
  alias WalletWeb.WalletController.TransactionJSON

  def send_deposit(transaction = %Transaction{}) do
    json = TransactionJSON.render(transaction)
    case Kaffe.Producer.produce_sync("deposit", Jason.encode!(json)) do
      :ok ->
        {:ok, json}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
