defmodule Wallet.TransactionsTest do
  use Wallet.DataCase
  alias Wallet.Transactions
  alias Wallet.Wallets

  setup do
    {:ok, wallet1} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("100.0")})
    {:ok, wallet2} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("50.0")})

    {:ok, %{wallet1: wallet1, wallet2: wallet2}}
  end

  describe "add_to_wallet_by_user/2" do
    test "adds amount to wallet balance", context do
      assert {:ok, _transaction} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    end

    test "returns error for negative amount", context do
      assert {:error, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, -50.0)
    end

    test "returns error for invalid amount type", context do
      assert {:error, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, "invalid")
    end
  end

  describe "withdraw_to_wallet_by_user/2" do
    test "withdraws amount from wallet balance", context do
      assert {:ok, _transaction} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    end

    test "returns error for negative amount", context do
      assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, -50.0)
    end

    test "returns error for invalid amount type", context do
      assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, "invalid")
    end

    test "returns error for insufficient funds", context do
      assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 150.0)
    end
  end

  describe "register_transaction/1" do
    test "registers a transaction", context do
      transaction_json = %{
        "amount" => 50.0,
        "operation" => "deposit",
        "wallet_origin_number" => context[:wallet1].number,
        "wallet_origin_id" => context[:wallet1].id
      }

      assert {:ok, _transaction} = Transactions.register_transaction(transaction_json)
    end

    test "returns error for invalid transaction", context do
      transaction_json = %{
        "amount" => "invalid",
        "operation" => "deposit",
        "wallet_origin_number" => context[:wallet1].number,
        "wallet_origin_id" => context[:wallet1].id
      }

      assert {:error, _} = Transactions.register_transaction(transaction_json)
    end
  end

  describe "transfer_to_wallet_by_user/3" do
    test "returns error for failed transaction", context do
      assert {:error, _} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 200.0)
    end
  end
end
