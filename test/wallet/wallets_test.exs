defmodule Wallet.WalletsTest do
  use Wallet.DataCase, async: true

  alias Wallet.Wallets
  alias Wallet.Wallet

  @valid_attrs %{user_id: Ecto.UUID.generate()}
  @invalid_attrs %{}

  describe "create_wallet/1" do
    test "creates a wallet with valid attributes" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs)
      assert wallet.user_id == @valid_attrs.user_id
    end

    test "does not create a wallet with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end
  end
end
