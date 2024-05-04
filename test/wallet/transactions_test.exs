defmodule Wallet.TransactionsTest do
  use ExUnit.Case
  alias Wallet.Transactions
  alias Wallet.Wallets

  setup do
    {:ok, wallet1} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("100.0")})
    {:ok, wallet2} = Wallets.create_wallet(%{user_id: Ecto.UUID.generate(), balance: Decimal.new("50.0")})

    {:ok, %{wallet1: wallet1, wallet2: wallet2}}
  end

  test "add_to_wallet_by_user/2", context do
    assert {:ok, _wallet} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    assert {:error, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, -50.0)
    assert {:error, _} = Transactions.add_to_wallet_by_user(context[:wallet1].user_id, "invalid")
  end

  test "withdraw_to_wallet_by_user/2", context do
    assert {:ok, _wallet} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 50.0)
    assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, 150.0)
    assert {:error, _} = Transactions.withdraw_to_wallet_by_user(context[:wallet1].user_id, "invalid")
  end

  test "tranfer_to_wallet_by_user/3", context do
    assert {:ok, _wallet} = Transactions.tranfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 50.0)
    assert {:error, _} = Transactions.tranfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, 150.0)
    assert {:error, _} = Transactions.tranfer_to_wallet_by_user(context[:wallet1].user_id, context[:wallet2].number, "invalid")
  end
end
