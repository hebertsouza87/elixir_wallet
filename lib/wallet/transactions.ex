defmodule Wallet.Transactions do
  alias Wallet.Wallets
  alias Wallet.Wallet

  def add_to_wallet_by_user(user_id, amount) do
    case validate_amount(amount) do
      :ok ->
        case Wallets.get_wallet_by_user(user_id) do
          nil -> {:error, {:not_found, "Wallet not found"}}
          wallet ->
            new_balance = Decimal.add(wallet.balance, Decimal.new(Float.to_string(amount)))

            Wallet.changeset(wallet, %{balance: new_balance})
            |> Wallets.update()
        end

      {:error, _} = error ->
        error
    end
  end

  def withdraw_to_wallet_by_user(user_id, amount) do
    case validate_amount(amount) do
      :ok ->
        case Wallets.get_wallet_by_user(user_id) do
          nil -> {:error, {:not_found, "Wallet not found"}}
          wallet ->
            new_balance = Decimal.sub(wallet.balance, Decimal.new(Float.to_string(amount)))

            if Decimal.compare(new_balance, Decimal.new("0.0")) == :lt do
              {:error, {:invalid, "Insufficient funds"}}
            else
              Wallet.changeset(wallet, %{balance: new_balance})
              |> Wallets.update()
            end
        end

      {:error, _} = error ->
        error
    end
  end

  def tranfer_to_wallet_by_user(user_id, to_wallet_number, amount) do
    case validate_amount(amount) do
      :ok ->
        case Wallets.get_wallet_by_user(user_id) do
          nil -> {:error, {:not_found, "Wallet not found"}}
          from_wallet ->
            case Wallets.get_wallet_by_number(to_wallet_number) do
              nil -> {:error, {:not_found, "To wallet not found"}}
              to_wallet ->
                if from_wallet.id == to_wallet.id do
                  {:error, {:invalid, "Same wallet transfer not allowed"}}
                else
                  new_balance_from = Decimal.sub(from_wallet.balance, Decimal.new(Float.to_string(amount)))

                  if Decimal.compare(new_balance_from, Decimal.new("0.0")) == :lt do
                    {:error, {:invalid, "Insufficient funds"}}
                  else
                    new_balance_to = Decimal.add(to_wallet.balance, Decimal.new(Float.to_string(amount)))

                    Wallet.changeset(to_wallet, %{balance: new_balance_to})
                    |> Wallets.update()

                    Wallet.changeset(from_wallet, %{balance: new_balance_from})
                    |> Wallets.update()
                  end
                end
            end
        end

      {:error, _} = error ->
        error
    end
  end

  defp correct_decimal_places?(amount) do
    Float.to_string(amount)
    |> String.split(".")
    |> Enum.at(1)
    |> String.length() <= 2
  end

  defp validate_amount(amount) do
    cond do
      !is_float(amount) ->
        {:error, {:invalid, "Amount must be a float"}}

      !correct_decimal_places?(amount) ->
        {:error, {:invalid, "Amount must have max two decimal places"}}

      true ->
        :ok
    end
  end
end
