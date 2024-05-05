defmodule Wallet.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @operation_types [:deposit, :withdraw, :transfer]

  schema "transactions" do
    field :amount, :decimal
    field :operation, Ecto.Enum, values: @operation_types
    field :wallet_id, Ecto.UUID
    field :wallet_origin_number, :integer
    field :wallet_destination_number, :integer

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :operation, :wallet_id, :wallet_origin_number, :wallet_destination_number])
    |> validate_required([:amount, :operation, :wallet_id])
    |> validate_transfer_fields()
  end

  defp validate_transfer_fields(changeset) do
    operation = get_field(changeset, :operation)

    case operation do
      :transfer ->
        changeset
        |> validate_required([:wallet_origin_number, :wallet_destination_number])
      _ ->
        changeset
    end
  end
end
