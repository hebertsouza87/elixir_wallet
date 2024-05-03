defmodule Wallet.Wallets do
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
      {:error, "Invalid wallet"}
    end
  end

  def get_wallet_by_user(user_id) do
    Repo.get_by(Wallet, user_id: user_id)
  end

  def get_wallet_by_number(number) do
    Repo.get_by(Wallet, number: number)
  end
end
