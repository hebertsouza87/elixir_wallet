defmodule Wallet.TransactionsTest do
  import Wallet.Factory

  use Wallet.DataCase
  alias Wallet.Transactions

  setup do
    wallet1 = insert(:wallet)
    wallet2 = insert(:wallet)

    {:ok, %{wallet1: wallet1, wallet2: wallet2}}
  end

  describe "add_to_wallet_by_user/2" do
    test "adds amount to wallet balance", context do
      assert {:ok, _transaction} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    end

    test "returns error for negative amount", context do
      assert {:bad_request, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, -50.0)
    end

    test "returns error for invalid amount type", context do
      assert {:bad_request, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, "invalid")
    end
  end

  describe "withdraw_to_wallet_by_user/2" do
    test "withdraws amount from wallet balance", context do
      assert {:ok, _transaction} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    end

    test "returns error for negative amount", context do
      assert {:bad_request, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, -50.0)
    end

    test "returns error for invalid amount type", context do
      assert {:bad_request, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, "invalid")
    end

    test "returns error for insufficient funds", context do
      assert {:bad_request, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 150.0)
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

      assert {:bad_request, _} = Transactions.register_transaction(transaction_json)
    end
  end

  describe "transfer_to_wallet_by_user/3" do
    test "returns error for failed transaction", context do
      assert {:bad_request, _} = Transactions.transfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 200.0)
    end
  end
end
