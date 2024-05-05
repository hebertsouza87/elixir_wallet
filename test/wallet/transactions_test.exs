defmodule Wallet.TransactionsTest do
  use ExUnit.Case
  alias Wallet.Transactions
  alias Wallet.Wallets

  setup do
    {:ok, wallet1} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("100.0")})
    {:ok, wallet2} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("50.0")})

    {:ok, %{wallet1: wallet1, wallet2: wallet2}}
  end

  describe "add_to_wallet_by_user/2" do
    test "adds amount to wallet balance", context do
      assert {:ok, _wallet} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, 50.0)
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
      assert {:ok, _wallet} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    end

    test "returns error for insufficient funds", context do
      assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 150.0)
    end

    test "returns error for invalid amount type", context do
      assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, "invalid")
    end
  end

  describe "transfer_to_wallet_by_user/3" do
    test "transfers amount between wallets", context do
      assert {:ok, _wallet} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 50.0)
    end

    test "returns error for transferring to same wallet", context do
      assert {:error, _} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet1].number, 50.0)
    end

    test "returns error for insufficient funds", context do
      assert {:error, _} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 150.0)
    end

    test "returns error for invalid amount type", context do
      assert {:error, _} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, "invalid")
    end
  end
end
