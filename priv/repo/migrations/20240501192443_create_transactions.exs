defmodule Wallet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal, null: false
      add :user_id, :uuid, null: false
      add :operation, :string, null: false

      timestamps()
    end

    create index(:transactions, [:user_id])
  end
end
