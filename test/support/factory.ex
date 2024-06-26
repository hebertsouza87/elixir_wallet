defmodule Wallet.Factory do
  use ExMachina.Ecto, repo: Wallet.Repo

  def wallet_factory do
    %Wallet.Wallet{
      user_id: Ecto.UUID.generate(),
      balance: Decimal.new("100.0"),
      number: :rand.uniform(1_000_000_000)
    }
  end
end
