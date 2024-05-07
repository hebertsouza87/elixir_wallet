defmodule Wallet.Kafka.ProducerTest do
  use ExUnit.Case, async: true

  alias Wallet.Kafka.Producer
  alias Wallet.Transaction

  describe "send_deposit/1" do
    test "sends a deposit for a valid transaction" do
      transaction = %Transaction{wallet_origin_id: Ecto.UUID.generate(), wallet_destination_id: 50, amount: 100}

      assert {:ok, _} = Producer.send_deposit(transaction)
    end

    test "returns error for an invalid transaction" do
      error = {:error, "Invalid transaction"}

      assert error == Producer.send_deposit(error)
    end
  end

  describe "produce_sync/2" do
    test "produces a message for a valid json and topic" do
      json = %{wallet_origin_id: Ecto.UUID.generate(), wallet_destination_id: 50, amount: 100}
      topic = "deposit"

      assert {:ok, ^json} = Producer.produce_sync(json, topic)
    end
  end
end
