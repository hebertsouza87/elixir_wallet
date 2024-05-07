defmodule Wallet.Kafka.Producer do
  require Logger

  alias Wallet.Transaction
  alias WalletWeb.WalletController.TransactionJSON

  def send_deposit(transaction = %Transaction{}) do
    transaction
    |> TransactionJSON.render()
    |> produce_sync("deposit")
    |> telemetry_event(transaction)
  end

  def send_deposit({error, reason}), do: {error, reason}

  defp produce_sync(json, topic) do
    case Jason.encode(json) do
      {:ok, encoded_json} ->
        Kaffe.Producer.produce_sync(topic, encoded_json)
        Logger.info("Deposit message sent: #{encoded_json}")
        {:ok, json}
      {:error, reason} ->
        Logger.error("Error encoding deposit message: #{reason}")
        {:error, reason}
    end
  end

  defp telemetry_event({:ok, _json}, transaction = %Transaction{}) do
    :telemetry.execute([:kafka, :deposit, :producer], %{id: transaction.id})
    {:ok, transaction}
  end
end
