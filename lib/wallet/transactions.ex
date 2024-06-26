defmodule Wallet.Transactions do
  @moduledoc """
  Módulo responsável por lidar com transações de carteira.
  """

  require Logger

  alias Ecto.Multi
  alias Wallet.Repo
  alias Wallet.Wallets
  alias Wallet.Transaction

  @doc """
  Processa uma transação a partir de um json
  """
  def process_transaction_json(transaction_json) do
    Logger.info("Registering transaction: #{inspect(transaction_json)}")

    with :ok <- validate_amount(transaction_json["amount"]),
         {:ok, wallet} <- Wallets.get_and_lock_wallet_by_number(transaction_json["wallet_origin_number"]),
         new_balance <- calculate_new_balance(wallet, transaction_json["amount"], transaction_json["operation"]),
         :ok <- validate_sufficient_funds(new_balance) do

      Multi.new()
      |> Multi.run(:update_wallet_balance, fn _repo, _changes -> Wallets.update_wallet_balance(wallet, new_balance) end)
      |> create_transaction_multi(transaction_json, :create_transaction)
      |> Repo.transaction()
      |> handle_transaction_result()
    end
  end

  @doc """
  Transfere uma quantidade de uma carteira para outra.
  """
  def process_transfer({:ok, user_id}, to_wallet_number, amount) do
    :telemetry.execute([:transfer, :started], %{amount: amount})
    Logger.info("Transferring from wallet of user #{user_id} to wallet #{to_wallet_number}")

    with :ok <- validate_amount(amount),
        {:ok, from_wallet} <- Wallets.get_and_lock_wallet_by_user(user_id),
        {:ok, to_wallet} <- Wallets.get_and_lock_wallet_by_number(to_wallet_number),
        :ok <- validate_same_wallet(from_wallet, to_wallet),
        new_balance_from <- calculate_new_balance(from_wallet, amount, :withdraw),
        :ok <- validate_sufficient_funds(new_balance_from),
        new_balance_to <- calculate_new_balance(to_wallet, amount, :deposit) do

      Multi.new()
      |> Multi.run(:update_from_wallet, fn _repo, _changes -> Wallets.update_wallet_balance(from_wallet, new_balance_from) end)
      |> Multi.run(:update_to_wallet, fn _repo, _changes -> Wallets.update_wallet_balance(to_wallet, new_balance_to) end)
      |> create_transactions_multi(amount, from_wallet, to_wallet)
      |> Repo.transaction()
      |> handle_transaction_result()
    end
  end

  def process_transaction({:ok, user_id}, amount, operation) do
    :telemetry.execute([operation, :started], %{amount: amount})
    Logger.info("#{operation |> to_string |> String.capitalize} #{amount} to wallet of user #{user_id}")

    with :ok <- validate_amount(amount),
         {:ok, wallet} <- Wallets.get_wallet_by_user(user_id),
         new_balance <- calculate_new_balance(wallet, amount, operation),
         :ok <- validate_sufficient_funds(new_balance) do

      Multi.new()
      |> Multi.run(:update_wallet_balance, fn _repo, _changes -> Wallets.update_wallet_balance(wallet, new_balance) end)
      |> create_transaction_multi(%{
          wallet_origin_id: wallet.id,
          wallet_origin_number: wallet.number,
          amount: amount,
          operation: operation,
        }, :create_transaction)
      |> Repo.transaction()
      |> handle_transaction_result()
    end
  end

  defp calculate_new_balance(wallet, amount, :withdraw), do: Decimal.sub(wallet.balance, Decimal.new(Float.to_string(amount)))
  defp calculate_new_balance(wallet, amount, :deposit), do: Decimal.add(wallet.balance, Decimal.new(Float.to_string(amount)))
  defp calculate_new_balance(wallet, amount, "deposit"), do: calculate_new_balance(wallet, amount, :deposit)
  defp calculate_new_balance(wallet, amount, "withdraw"), do: calculate_new_balance(wallet, amount, :withdraw)

  defp correct_decimal_places?(amount) do
    Float.to_string(amount)
    |> String.split(".")
    |> Enum.at(1)
    |> String.length() <= 2
  end

  defp create_transaction_multi(multi, attrs, operation_name) do
    Multi.insert(multi, operation_name, Transaction.changeset(%Transaction{}, attrs))
  end

  defp create_transactions_multi(multi, amount, from_wallet, to_wallet) do
    multi
    |> Multi.insert(:create_transaction_from, Transaction.changeset(%Transaction{}, %{
      wallet_id: from_wallet.id,
      amount: amount,
      operation: :transfer,
      wallet_destination_number: to_wallet.number,
      wallet_destination_id: to_wallet.id,
      wallet_origin_number: from_wallet.number,
      wallet_origin_id: from_wallet.id,
    }))
    |> Multi.insert(:create_transaction_to, Transaction.changeset(%Transaction{}, %{
      wallet_id: to_wallet.id,
      amount: amount,
      operation: :transfer,
      wallet_destination_number: to_wallet.number,
      wallet_destination_id: to_wallet.id,
      wallet_origin_number: from_wallet.number,
      wallet_origin_id: from_wallet.id,
    }))
  end

  defp handle_transaction_result({:ok, %{create_transaction: created_transaction}}) do
    Logger.info("Transaction registered: #{inspect(created_transaction)}")
    {:ok, created_transaction}
  end
  defp handle_transaction_result({:ok, %{update_from_wallet: _, update_to_wallet: _, create_transaction_from: created_transaction_from, create_transaction_to: created_transaction_to} = _result}) do
    Logger.info("Transaction registered from: #{inspect(created_transaction_from)} to: #{inspect(created_transaction_to)} ")
    {:ok, created_transaction_from}
  end
  defp handle_transaction_result({:error, error, message, _}), do: {:error, {error, message}}

  defp validate_amount(amount) do
    cond do
      !is_float(amount) ->
        {:bad_request, "Amount must be a float"}

      !correct_decimal_places?(amount) ->
        {:bad_request, "Amount must have max two decimal places"}

      Decimal.compare(Decimal.new(Float.to_string(amount)), Decimal.new("0.0")) in [:eq, :lt] ->
        {:bad_request, "Amount must be greater than 0"}

      true ->
        :ok
    end
  end

  defp validate_same_wallet(from_wallet, to_wallet) do
    if from_wallet.id == to_wallet.id, do: {:bad_request, "Same wallet transfer not allowed"}, else: :ok
  end

  defp validate_sufficient_funds(new_balance) do
    if Decimal.compare(new_balance, Decimal.new("0.0")) == :lt, do: {:bad_request, "Insufficient funds"}, else: :ok
  end
end
