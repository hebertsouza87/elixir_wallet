defmodule Wallet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal, null: false
      add :wallet_id, references(:wallets, type: :uuid), null: false
      add :operation, :string, null: false
      add :wallet_origin_number, :integer, null: true
      add :wallet_destination_number, :integer, null: true

      timestamps()
    end

    create index(:transactions, [:wallet_id])
    create index(:transactions, [:wallet_origin_number])
    create index(:transactions, [:wallet_destination_number])
  end
end
