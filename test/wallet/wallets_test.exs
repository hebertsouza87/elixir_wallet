defmodule Wallet.WalletsTest do
  use Wallet.DataCase, async: true

  alias Wallet.Wallets
  alias Wallet.Wallet

  @valid_user_id "818f2e77-3610-4c74-939d-ea67ac2f2ef2"

  describe "Wallets" do
    test "create_wallet/1 with valid data creates a wallet" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      assert wallet.user_id == @valid_user_id
      assert wallet.number != nil
    end

    test "create_wallet/1 with attributes creates a wallet" do
      attrs = %{user_id: @valid_user_id, balance: 10.0}
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(attrs)
      assert wallet.user_id == attrs.user_id
      assert wallet.balance == Decimal.new(Float.to_string(attrs.balance))
    end

    test "create_wallet/1 fails when wallet already exists for user_id" do
      Wallets.create_wallet({:ok, @valid_user_id})
      assert {:error, _message} = Wallets.create_wallet({:ok, @valid_user_id})
    end

    test "get_and_lock_wallet_by_user/1 returns error when user_id is nil" do
      assert {:bad_request, "Invalid user_id"} == Wallets.get_and_lock_wallet_by_user(nil)
    end

    test "get_and_lock_wallet_by_number/1 returns error when wallet number is nil" do
      assert {:bad_request, "Invalid wallet number"} == Wallets.get_and_lock_wallet_by_number(nil)
    end

    test "update/1 with valid changeset updates the wallet" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      changeset = Wallet.changeset(wallet, %{balance: 10.00})
      assert {:ok, %Wallet{} = updated_wallet} = Wallets.update(changeset)
      assert updated_wallet.balance == Decimal.new("10.0")
    end

    test "update/1 with balance having more than two decimal places returns an error" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      changeset = Wallet.changeset(wallet, %{balance: 10.001})
      assert {:bad_request, _message} = Wallets.update(changeset)
    end

    test "get_wallet_by_user returns wallet for existing user_id" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      assert {:ok, %Wallet{}} = Wallets.get_wallet_by_user({:ok, wallet.user_id})
    end

    test "get_wallet_by_user returns error for non-existing user_id" do
      non_existing_user_id = "00000000-0000-0000-0000-000000000000"
      assert {:not_found, _} = Wallets.get_wallet_by_user(non_existing_user_id)
    end

    test "get_wallet_by_number returns wallet for existing number" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      assert {:ok, %Wallet{}} = Wallets.get_wallet_by_number(wallet.number)
    end

    test "get_wallet_by_number returns error for non-existing number" do
      assert {:not_found, _} = Wallets.get_wallet_by_number(-1)
    end

    test "get_and_lock_wallet_by_user locks and returns the wallet for a given user_id" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      assert {:ok, %Wallet{}} = Wallets.get_and_lock_wallet_by_user(wallet.user_id)
    end

    test "get_and_lock_wallet_by_user returns error for non-existing user_id" do
      non_existing_user_id = "00000000-0000-0000-0000-000000000000"
      assert {:not_found, "Wallet not found"} = Wallets.get_and_lock_wallet_by_user(non_existing_user_id)
    end

    test "get_and_lock_wallet_by_number locks and returns the wallet for a given wallet number" do
      {:ok, wallet} = Wallets.create_wallet({:ok, @valid_user_id})
      assert {:ok, %Wallet{}} = Wallets.get_and_lock_wallet_by_number(wallet.number)
    end

    test "get_and_lock_wallet_by_number returns error for non-existing number" do
      assert {:not_found, "Wallet not found"} = Wallets.get_and_lock_wallet_by_number("-1")
    end
  end
end
