defmodule Wallet.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";"

    create table(:wallets, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :balance, :decimal, null: false, default: 0
      add :user_id, :uuid, null: false
      add :number, :serial, null: false

      timestamps()
    end

    create unique_index(:wallets, [:user_id])
    create unique_index(:wallets, [:number])
  end
end