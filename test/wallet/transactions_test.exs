defmodule Wallet.TransactionTest do
  import Wallet.Factory

  use Wallet.DataCase, async: true

  alias Wallet.Transaction
  alias Wallet.Transactions
  alias Wallet.Repo
  alias Wallet.Wallets
  alias Wallet.Wallet

  setup do
    wallet = insert(:wallet)
    {:ok, wallet: wallet, user_id: wallet.user_id}
  end

  describe "process_transfer/3" do
    test "validates and processes a transfer from one wallet to another", %{user_id: user_id} do
      wallet_to = insert(:wallet)
      to_wallet_number = wallet_to.number
      amount = 10.0

      result = Transactions.process_transfer({:ok, user_id}, to_wallet_number, amount)

      assert {:ok, _} = result

      {:ok, updated_wallet_from} = Wallets.get_wallet_by_user(user_id)
      {:ok, updated_wallet_to} = Wallets.get_wallet_by_number(to_wallet_number)

      assert updated_wallet_from.balance == Decimal.new("90.0")
      assert updated_wallet_to.balance == Decimal.new("110.0")
    end
  end

  describe "process_transaction/3" do
    test "validates and processes a deposit transaction", %{user_id: user_id} do
      amount = 10.0
      operation = :deposit

      result = Transactions.process_transaction({:ok, user_id}, amount, operation)

      assert {:ok, _} = result

      {:ok, updated_wallet} = Wallets.get_wallet_by_user(user_id)
      assert updated_wallet.balance == Decimal.new("110.0")
    end

    test "validates and processes a withdraw transaction", %{user_id: user_id} do
      amount = 10.0
      operation = :withdraw

      result = Transactions.process_transaction({:ok, user_id}, amount, operation)

      assert {:ok, _} = result

      {:ok, updated_wallet} = Wallets.get_wallet_by_user(user_id)
      assert updated_wallet.balance == Decimal.new("90.0")
    end
  end
end
