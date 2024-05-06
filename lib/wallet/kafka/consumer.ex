defmodule Wallet.Kafka.Consumer do
  def handle_messages(messages) do
    for %{key: key, value: value} <- messages do
      handle_message(key, value)
    end
    :ok
  end

  defp handle_message("deposit", value) do
    Logget.info("Processing deposit: " <> value)
    value
    |> Jason.decode!()
    |> Wallet.Transactions.register_transaction()
  end

  defp handle_message(key, message) do
    Logger.error("Message not expected: " <> key <> " - " <> message)
    :error
  end
end
