defmodule Wallet.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

 @primary_key {:id, Ecto.UUID, autogenerate: true}
 schema "wallets" do
    field :balance, :decimal, default: 0.0
    field :number, :integer
    field :user_id, Ecto.UUID

    timestamps()
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :balance])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
  end
end
