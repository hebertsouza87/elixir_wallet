defmodule Wallet.WalletsTest do
  use Wallet.DataCase, async: true

  alias Wallet.Wallets
  alias Wallet.Wallet

  @valid_attrs %{user_id: "818f2e77-3610-4c74-939d-ea67ac2f2ef2"}

  describe "Wallets" do
    test "create_wallet/1 with valid data creates a wallet" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs)
      assert wallet.user_id == "818f2e77-3610-4c74-939d-ea67ac2f2ef2"
      assert wallet.number != nil
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
      assert {:error, "Invalid wallet"} = Wallets.update(changeset)
    end

    test "get_wallet_by_user/1 returns the correct wallet" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert %Wallet{} = Wallets.get_wallet_by_user(wallet.user_id)
    end

    test "get_wallet_by_number/1 returns the correct wallet" do
      {:ok, wallet} = Wallets.create_wallet(@valid_attrs)
      assert %Wallet{} = Wallets.get_wallet_by_number(wallet.number)
    end
  end
end
