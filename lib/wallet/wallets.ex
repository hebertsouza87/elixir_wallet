defmodule Wallet.Wallets do
  alias Wallet.Repo
  alias Wallet.Wallet

  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert(returning: true)
  end
end
