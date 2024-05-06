defmodule Wallet.Kafka.ConsumerTest do
  use ExUnit.Case
  alias Wallet.Kafka.Consumer
  alias Wallet.Transactions
  alias Wallet.Wallet

  test "handle_messages/1 processes a list of messages" do
    messages = [%{key: "deposit", value: ~s({"amount": "100.0", "user_id": "123"})}]
    assert Consumer.handle_messages(messages) == :ok
  end

  test "handle_message/2 processes a deposit message" do
    value = ~s({"amount": "100.0", "user_id": "123"})
    assert Consumer.handle_message("deposit", value) == {:ok, %Wallet{}}
  end

  test "handle_message/2 returns :error for an unexpected message" do
    assert Consumer.handle_message("unexpected", "message") == :error
  end
end
