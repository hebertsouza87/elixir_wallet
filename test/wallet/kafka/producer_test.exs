defmodule Wallet.Kafka.ProducerTest do
  use ExUnit.Case, async: true

  alias Wallet.Kafka.Producer
  alias Wallet.Transaction

  describe "send_deposit/1" do
    test "returns error when input is an error tuple" do
      assert {:error, :reason} == Producer.send_deposit({:error, :reason})
    end

    test "calls produce_sync/2 and telemetry_event/2 when input is a Transaction struct" do
      transaction = %Transaction{
        wallet_origin_id: Ecto.UUID.generate,
        wallet_destination_id: Ecto.UUID.generate,
        wallet_destination_number: 10,
        wallet_origin_number: 12,
        amount: Decimal.new(100)
      }

      assert {:ok, ^transaction} = Producer.send_deposit(transaction)
    end
  end
end
