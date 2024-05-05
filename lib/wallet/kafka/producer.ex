defmodule Wallet.Kafka.Producer do
  def send_deposit(transaction = %Wallet.Transaction{}) do
    Kaffe.Producer.produce_sync("deposit", transaction)
  end
end
