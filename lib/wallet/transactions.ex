defmodule Wallet.Transactions do
  alias Wallet.Wallets
  alias Wallet.Wallet

  def add_to_wallet_by_user(user_id, amount) do
    IO.inspect(user_id, label: "user_id")
    IO.inspect(amount, label: "amount")

    # Convert the float amount to a string, then to a Decimal
    amount = Decimal.new(Float.to_string(amount))

    wallet = Wallets.get_wallet_by_user(user_id)

    new_balance = Decimal.add(wallet.balance, amount)

    Wallet.changeset(wallet, %{balance: new_balance})
    |> Wallets.update()

  end
end
