defmodule Wallet.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :balance, :decimal, null: false, default: 0
      add :user_id, :uuid, null: false

      timestamps()
    end

    create unique_index(:wallets, [:user_id])
  end
end
