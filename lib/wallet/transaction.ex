defmodule Wallet.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @operation_types [:deposit, :withdraw, :transfer]

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "transactions" do
    field :amount, :decimal
    field :operation, Ecto.Enum, values: @operation_types
    field :wallet_origin_id, Ecto.UUID
    field :wallet_destination_id, Ecto.UUID
    field :wallet_origin_number, :integer
    field :wallet_destination_number, :integer

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :operation, :wallet_origin_number, :wallet_destination_number, :wallet_origin_id, :wallet_destination_id])
    |> validate_required([:amount, :operation, :wallet_origin_id])
    |> validate_transfer_fields()
  end

  defp validate_transfer_fields(changeset) do
    operation = get_field(changeset, :operation)

    case operation do
      :transfer ->
        changeset
        |> validate_required([:wallet_origin_number, :wallet_destination_number, :wallet_destination_id])
      _ ->
        changeset
    end
  end
end
