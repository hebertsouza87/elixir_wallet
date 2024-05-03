defmodule Wallet.WalletsTest do
  use Wallet.DataCase, async: true

  alias Wallet.Wallets
  alias Wallet.Wallet

  @valid_attrs %{field1: "value1", field2: "value2"} # substitua field1, field2, etc. pelos nomes reais dos campos do seu esquema Wallet

  describe "create_wallet/1" do
    test "creates a wallet with valid attributes" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs)
      assert wallet.field1 == "value1" # substitua field1 pelo nome real do campo
      assert wallet.field2 == "value2" # substitua field2 pelo nome real do campo
    end

    test "does not create a wallet with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(%{})
    end
  end
end
