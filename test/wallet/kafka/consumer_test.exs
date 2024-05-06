defmodule Wallet.Kafka.ConsumerTest do
  use ExUnit.Case
  alias Wallet.Kafka.Consumer
  alias Wallet.Wallet

  test "handle_messages/1 processes a list of messages" do
    messages = [%{key: "deposit", value: ~s({"amount": "100.0", "wallet_origin_id": "2b0a6560-bd29-43e6-bd1d-29fb64b1f89f", "wallet_origin_number": 123456})},
                %{key: "deposit", value: ~s({"amount": "100.0", "wallet_origin_id": "2b0a6560-bd29-43e6-bd1d-29fb64b1f89f", "wallet_origin_number": 123456})}]
    assert Consumer.handle_messages(messages) == :ok
  end

  test "handle_message/2 processes a deposit message" do
    value = ~s({"amount": 100.0, "wallet_origin_id": "2b0a6560-bd29-43e6-bd1d-29fb64b1f89f", "wallet_origin_number": 123456})
    assert Consumer.handle_message("deposit", value) == {:ok, %Wallet{}}
  end

  test "handle_message/2 returns :error for an unexpected message" do
    assert Consumer.handle_message("unexpected", "message") == :error
  end
end
