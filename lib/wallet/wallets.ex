defmodule Wallet.Wallets do
  import Ecto.Query
  alias Wallet.Repo
  alias Wallet.Wallet

  def create_wallet(attrs \\ %{}) do
    case valid_uuid?(attrs["user_id"] || attrs[:user_id]) do
      true ->
        changeset = Wallet.changeset(%Wallet{}, attrs)

        if changeset.valid? do
          case Repo.get_by(Wallet, user_id: attrs["user_id"] || attrs[:user_id]) do
            nil ->
              Repo.insert(changeset, returning: true)
            _wallet ->
              {:invalid, "Wallet already exists for this user_id"}
          end
        else
          {:error, changeset}
        end
      false ->
        {:invalid, "Invalid user_id format. Must be a valid UUID."}
    end
  end

  defp valid_uuid?(value) do
    case Ecto.UUID.cast(value) do
      {:ok, _uuid} -> true
      :error -> false
    end
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

  def get_wallet_by_user(user_id) do
    case Repo.get_by(Wallet, user_id: user_id) do
      nil -> {:not_found, {:not_found, "Wallet not found"}}
      wallet -> {:ok, wallet}
    end
  end

  def get_wallet_by_number(wallet_number) do
    case Repo.get_by(Wallet, number: wallet_number) do
      nil -> {:not_found, {:not_found, "Wallet not found"}}
      wallet -> {:ok, wallet}
    end
  end

  def get_and_lock_wallet_by_user(user_id) do
    query = from w in Wallet, where: w.user_id == ^user_id, lock: "FOR UPDATE"
    case Repo.one(query) do
      nil -> {:error, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end

  def get_and_lock_wallet_by_number(wallet_number) do
    query = from w in Wallet, where: w.number == ^wallet_number, lock: "FOR UPDATE"
    case Repo.one(query) do
      nil -> {:error, "Wallet not found"}
      wallet -> {:ok, wallet}
    end
  end
end
