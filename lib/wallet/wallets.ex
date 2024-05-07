defmodule Wallet.Wallets do
  import Ecto.Query
  alias Wallet.Repo
  alias Wallet.Wallet

  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert(returning: true)
  end

  def update(changeset) do
    if changeset.valid? do
      Repo.update(changeset, returning: true)
    else
      {:invalid, "Invalid wallet"}
    end
  end

  def update_wallet_balance(wallet, new_balance) do
    Wallet.changeset(wallet, %{balance: new_balance})
    |> update()
  end

  def get_wallet_by_user({:ok, user_id}) do get_wallet_by_user(user_id) end

  def get_wallet_by_user(user_id) do
    case Repo.get_by(Wallet, user_id: user_id) do
      nil -> {:not_found, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end

  def get_wallet_by_number(wallet_number) do
    case Repo.get_by(Wallet, number: wallet_number) do
      nil -> {:not_found, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end

  def get_and_lock_wallet_by_user(user_id) do
    query = from w in Wallet, where: w.user_id == ^user_id, lock: "FOR UPDATE"
    case Repo.one(query) do
      nil -> {:not_found, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end

  def get_and_lock_wallet_by_number(wallet_number) do
    query = from w in Wallet, where: w.number == ^wallet_number, lock: "FOR UPDATE"
    case Repo.one(query) do
      nil -> {:not_found, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end
end
