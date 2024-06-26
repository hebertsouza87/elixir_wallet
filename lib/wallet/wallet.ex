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
    |> cast(attrs, [:user_id, :balance, :number])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
    |> validate_decimal(:balance)
    |> validate_uuid(:user_id)
  end

  defp validate_uuid(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case Ecto.UUID.cast(value) do
        {:ok, _} -> []
        :error -> [{field, "must be a valid UUID"}]
      end
    end)
  end

  defp validate_decimal(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case Decimal.to_string(value) |> String.split(".") |> Enum.at(1) |> String.length() <= 2 do
        true -> []
        false -> [{field, "must have at most two decimal places"}]
      end
    end)
  end
end
