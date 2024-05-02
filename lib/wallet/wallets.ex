defmodule Wallet.Wallets do
  alias Wallet.Repo
  alias Wallet.Wallet

  def create_wallet(attrs \\ %{}) do
    IO.inspect(attrs, label: "attrs")

    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end
end
