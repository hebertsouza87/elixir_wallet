defmodule Wallet.Kafka.Producer do
  require Logger

  alias Wallet.Transaction
  alias WalletWeb.WalletController.TransactionJSON

  def send_deposit(transaction = %Transaction{}) do
    json = TransactionJSON.render(transaction)
    case Kaffe.Producer.produce_sync("deposit", Jason.encode!(json)) do
      :ok ->
        Logger.info("Deposit message sent: #{Jason.encode!(json)}")
        :telemetry.execute([:kafka, :deposit, :producer], %{id: json["id"]})
        {:ok, json}
      {:error, reason} ->
        {:error, reason}
    end
  end
  def send_deposit({error, reason}), do: {error, reason}
end
