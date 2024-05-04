defmodule Wallet.Transactions do
  alias Wallet.Repo
  alias Wallet.Wallets
  alias Wallet.Wallet

  def add_to_wallet_by_user(user_id, amount) do
    with :ok <- validate_amount(amount),
         {:ok, wallet} <- get_wallet_by_user(user_id),
         {:ok, new_balance} <- calculate_new_balance(wallet, amount, :add) do
      update_wallet_balance(wallet, new_balance)
    else
      error -> error
    end
  end

  def withdraw_to_wallet_by_user(user_id, amount) do
    with :ok <- validate_amount(amount),
         {:ok, wallet} <- get_wallet_by_user(user_id),
         {:ok, new_balance} <- calculate_new_balance(wallet, amount, :sub),
         :ok <- validate_sufficient_funds(new_balance) do
      update_wallet_balance(wallet, new_balance)
    else
      error -> error
    end
  end

  def tranfer_to_wallet_by_user(user_id, to_wallet_number, amount) do
    with :ok <- validate_amount(amount),
         {:ok, from_wallet} <- get_wallet_by_user(user_id),
         {:ok, to_wallet} <- get_wallet_by_number(to_wallet_number),
         :ok <- validate_same_wallet(from_wallet, to_wallet),
         {:ok, new_balance_from} <- calculate_new_balance(from_wallet, amount, :sub),
         :ok <- validate_sufficient_funds(new_balance_from),
         {:ok, new_balance_to} <- calculate_new_balance(to_wallet, amount, :add) do

      from_wallet_changeset = Ecto.Changeset.change(from_wallet, %{balance: new_balance_from})
      to_wallet_changeset = Ecto.Changeset.change(to_wallet, %{balance: new_balance_to})

      multi =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:update_to, to_wallet_changeset)
        |> Ecto.Multi.update(:update_from, from_wallet_changeset)

      case Repo.transaction(multi) do
        {:ok, %{update_from: updated_from_wallet}} ->
          {:ok, updated_from_wallet}

        {:error, _, _, _} ->
          {:error, "Failed to transfer funds"}
      end
    else
      error -> error
    end
  end

  defp get_wallet_by_user(user_id) do
    case Wallets.get_wallet_by_user(user_id) do
      nil -> {:error, {:not_found, "Wallet not found"}}
      wallet -> {:ok, wallet}
    end
  end

  defp get_wallet_by_number(wallet_number) do
    case Wallets.get_wallet_by_number(wallet_number) do
      nil -> {:error, {:not_found, "To wallet not found"}}
      wallet -> {:ok, wallet}
    end
  end

  defp validate_same_wallet(from_wallet, to_wallet) do
    if from_wallet.id == to_wallet.id do
      {:error, {:invalid, "Same wallet transfer not allowed"}}
    else
      :ok
    end
  end

  defp calculate_new_balance(wallet, amount, operation) do
    new_balance =
      case operation do
        :sub -> Decimal.sub(wallet.balance, Decimal.new(Float.to_string(amount)))
        :add -> Decimal.add(wallet.balance, Decimal.new(Float.to_string(amount)))
      end

    {:ok, new_balance}
  end

  defp validate_sufficient_funds(new_balance) do
    if Decimal.compare(new_balance, Decimal.new("0.0")) == :lt do
      {:error, {:invalid, "Insufficient funds"}}
    else
      :ok
    end
  end

  defp update_wallet_balance(wallet, new_balance) do
    Wallet.changeset(wallet, %{balance: new_balance})
    |> Wallets.update()
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

      Decimal.compare(Decimal.new(Float.to_string(amount)), Decimal.new("0.0")) in [:eq, :lt] ->
        {:error, {:invalid, "Amount must be greater than 0"}}

      true ->
        :ok
    end
  end
end
