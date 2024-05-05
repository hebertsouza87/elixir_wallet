defmodule Wallet.WalletsTest do
  use Wallet.DataCase, async: true

  alias Wallet.Wallets
  alias Wallet.Wallet

  @valid_attrs %{user_id: "818f2e77-3610-4c74-939d-ea67ac2f2ef2"}
  @invalid_attrs %{user_id: nil}

  describe "Wallets" do
    test "create_wallet/1 with valid data creates a wallet" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs)
      assert wallet.user_id == "818f2e77-3610-4c74-939d-ea67ac2f2ef2"
      assert wallet.number != nil
    end

    test "create_wallet/1 with invalid data returns an error" do
      assert {:invalid, _changeset} = Wallets.create_wallet(@invalid_attrs)
    end

    test "create_wallet/1 fails when wallet already exists for user_id" do
      Wallets.create_wallet(@valid_attrs)
      assert {:invalid, _message} = Wallets.create_wallet(@valid_attrs)
    end

    test "update/1 with valid changeset updates the wallet" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      changeset = Wallet.changeset(wallet, %{balance: 10.00})
      assert {:ok, %Wallet{} = updated_wallet} = Wallets.update(changeset)
      assert updated_wallet.balance == Decimal.new("10.0")
    end

    test "update/1 with balance having more than two decimal places returns an error" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      changeset = Wallet.changeset(wallet, %{balance: 10.001})
      assert {:invalid, _message} = Wallets.update(changeset)
    end

    test "get_wallet_by_user returns wallet for existing user_id" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert {:ok, %Wallet{}} = Wallets.get_wallet_by_user(wallet.user_id)
    end

    test "get_wallet_by_user returns error for non-existing user_id" do
      assert_raise Ecto.Query.CastError, fn ->
        Wallets.get_wallet_by_user("non-existing-id")
      end
    end

    test "get_wallet_by_number returns wallet for existing number" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert {:ok, %Wallet{}} = Wallets.get_wallet_by_number(wallet.number)
    end

    test "get_wallet_by_number returns error for non-existing number" do
      assert {:not_found, _} = Wallets.get_wallet_by_number(-1)
    end

    test "get_and_lock_wallet_by_user locks and returns the wallet for a given user_id" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert {:ok, %Wallet{}} = Wallets.get_and_lock_wallet_by_user(wallet.user_id)
    end

    test "get_and_lock_wallet_by_user returns error for non-existing user_id" do
      non_existing_user_id = "00000000-0000-0000-0000-000000000000"
      assert {:error, "Wallet not found"} = Wallets.get_and_lock_wallet_by_user(non_existing_user_id)
    end

    test "get_and_lock_wallet_by_number locks and returns the wallet for a given wallet number" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert {:ok, %Wallet{}} = Wallets.get_and_lock_wallet_by_number(wallet.number)
    end

    test "get_and_lock_wallet_by_number returns error for non-existing number" do
      assert {:error, "Wallet not found"} = Wallets.get_and_lock_wallet_by_number("-1")
    end
  end
end
