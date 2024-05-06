defmodule Wallet.Kafka.ConsumerTest do
  import Wallet.Factory

  use ExUnit.Case
  alias Wallet.Kafka.Consumer
  alias Wallet.Wallet

  setup do
    wallet1 = insert(:wallet)
    {:ok, wallet1: wallet1}
  end

  test "handle_messages/1 processes a list of messages", %{wallet1: wallet1} do
    value = Jason.encode!(%{
      "amount" => 100.0,
      "wallet_origin_id" => wallet1.id,
      "wallet_origin_number" => wallet1.number,
      "operation" => "deposit"
    })
    messages = [%{key: "deposit", value: value}, %{key: "deposit", value: value}]
    assert Consumer.handle_messages(messages) == :ok
  end

  test "handle_message/2 processes a deposit message", %{wallet1: wallet1} do
    value = Jason.encode!(%{
      "amount" => 100.0,
      "wallet_origin_id" => wallet1.id,
      "wallet_origin_number" => wallet1.number
    })
    assert Consumer.handle_message("deposit", value) == {:ok, %Wallet{}}
  end

  test "handle_message/2 returns :error for an unexpected message", _context do
    assert Consumer.handle_message("unexpected", "message") == :error
  end
end
