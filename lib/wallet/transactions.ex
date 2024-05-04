defmodule Wallet.Transactions do
  alias Wallet.Wallets
  alias Wallet.Wallet

  def add_to_wallet_by_user(user_id, amount) do
    cond do
      !is_float(amount) ->
        {:error, {:invalid, "Amount must be a float"}}

      !correct_decimal_places?(amount) ->
        {:error, {:invalid, "Amount must have exactly two decimal places"}}

        true ->
          case Wallets.get_wallet_by_user(user_id) do
            nil -> {:error, {:not_found, "Wallet not found"}}
            wallet ->
              new_balance = Decimal.add(wallet.balance, Decimal.new(Float.to_string(amount)))

              Wallet.changeset(wallet, %{balance: new_balance})
              |> Wallets.update()
          end
    end
  end

  defp correct_decimal_places?(amount) do
    Float.to_string(amount)
    |> String.split(".")
    |> Enum.at(1)
    |> String.length() <= 2
  end

  # def withdraw_from_wallet(%Wallet{} = wallet, amount) do
  #   new_balance = wallet.balance - amount
  #   if new_balance < 0 do
  #     {:error, "Insufficient balance"}
  #   else
  #     wallet
  #     |> Wallet.changeset(%{balance: new_balance})
  #     |> Wallets.update()
  #   end
  # end

  # def transfer(%Wallet{} = from_wallet, %Wallet{} = to_wallet, amount) do
  #   with {:ok, _} <- withdraw_from_wallet(from_wallet, amount),
  #        {:ok, _} <- add_to_wallet(to_wallet, amount) do
  #     {:ok, "Transfer successful"}
  #   else
  #     _ -> {:error, "Transfer failed"}
  #   end
  # end
end
