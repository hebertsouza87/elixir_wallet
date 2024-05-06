defmodule Wallet.Transactions do
  @moduledoc """
  Módulo responsável por lidar com transações de carteira.
  """

  alias Ecto.Multi
  alias Wallet.Repo
  alias Wallet.Wallets
  alias Wallet.Transaction

  @doc """
  Adiciona uma quantidade à carteira de um usuário.
  """
  def add_to_wallet_by_user(user_id, amount) do
    with :ok <- validate_amount(amount),
         {:ok, wallet} <- Wallets.get_wallet_by_user(user_id),
         transaction = build_transaction(wallet, amount),
         :ok <- Wallet.Kafka.Producer.send_deposit(transaction) do
      {:ok, transaction}
    else
      error -> error
    end
  end

  @doc """
  Registra uma transação.
  """
  def register_transaction(transaction_json) do
    with :ok <- validate_amount(transaction_json["amount"]),
    {:ok, wallet} <- Wallets.get_and_lock_wallet_by_number(transaction_json["wallet_origin_number"]),
    new_balance <- calculate_new_balance(wallet, transaction_json["amount"], transaction_json["operation"]),
    :ok <- validate_sufficient_funds(new_balance) do

    multi = Multi.new()
    |> Multi.run(:update_wallet_balance, fn _repo, _changes ->
      Wallets.update_wallet_balance(wallet, new_balance)
    end)
    |> create_transaction_multi(transaction_json, :create_transaction)

    case Repo.transaction(multi) do
      {:ok, %{create_transaction: created_transaction}} ->
        {:ok, created_transaction}

      {:error, error, message, _} ->
        {:error, {error, message}}
    end
  end
end

  @doc """
  Retira uma quantidade da carteira de um usuário.
  """
  def withdraw_to_wallet_by_user(user_id, amount) do
    change_balance(user_id, amount, :withdraw)
  end

  @doc """
  Transfere uma quantidade de uma carteira para outra.
  """
  def transfer_to_wallet_by_user(user_id, to_wallet_number, amount) do
    with :ok <- validate_amount(amount),
         {:ok, from_wallet} <- Wallets.get_and_lock_wallet_by_user(user_id),
         {:ok, to_wallet} <- Wallets.get_and_lock_wallet_by_number(to_wallet_number),
         :ok <- validate_same_wallet(from_wallet, to_wallet),
         new_balance_from <- calculate_new_balance(from_wallet, amount, :withdraw),
         :ok <- validate_sufficient_funds(new_balance_from),
         new_balance_to <- calculate_new_balance(to_wallet, amount, :deposit) do

      multi = Multi.new()
      |> Multi.run(:update_from_wallet, fn _repo, _changes ->
        Wallets.update_wallet_balance(from_wallet, new_balance_from)
      end)
      |> Multi.run(:update_to_wallet, fn _repo, _changes ->
        Wallets.update_wallet_balance(to_wallet, new_balance_to)
      end)
      |> create_transaction_multi(%{
        wallet_id: from_wallet.id,
        amount: amount,
        operation: :transfer,
        wallet_destination_number: to_wallet.number,
        wallet_destination_id: to_wallet.id,
        wallet_origin_number: from_wallet.number,
        wallet_origin_id: from_wallet.id,
      }, :create_transaction_from)
      |> create_transaction_multi(%{
        wallet_id: to_wallet.id,
        amount: amount,
        operation: :transfer,
        wallet_destination_number: to_wallet.number,
        wallet_destination_id: to_wallet.id,
        wallet_origin_number: from_wallet.number,
        wallet_origin_id: from_wallet.id,
      }, :create_transaction_to)

      case Repo.transaction(multi) do
        {:ok, %{create_transaction_from: created_transaction}} ->
          {:ok, created_transaction}

        {:error, error, message, _} ->
          {:error, {error, message}}
      end
    else
      error -> error
    end
  end

  defp create_transaction_multi(multi, attrs, operation_name) do
    Multi.insert(multi, operation_name, Transaction.changeset(%Transaction{}, attrs))
  end

  defp build_transaction(wallet, amount) do
    %Transaction{
      id: Ecto.UUID.generate(),
      amount: amount,
      operation: :deposit,
      wallet_origin_id: wallet.id,
      wallet_origin_number: wallet.number
    }
  end

  defp change_balance(user_id, amount, operation) do
    with :ok <- validate_amount(amount),
         {:ok, wallet} <- Wallets.get_and_lock_wallet_by_user(user_id),
         new_balance <- calculate_new_balance(wallet, amount, operation),
         :ok <- validate_sufficient_funds(new_balance) do

      multi = Multi.new()
      |> Multi.run(:update_wallet_balance, fn _repo, _changes ->
        Wallets.update_wallet_balance(wallet, new_balance)
      end)
      |> create_transaction_multi(%{
          wallet_origin_id: wallet.id,
          wallet_origin_number: wallet.number,
          amount: amount,
          operation: operation,
        }, :create_transaction)

      case Repo.transaction(multi) do
        {:ok, %{create_transaction: created_transaction}} ->
          {:ok, created_transaction}

        {:error, error, message, _} ->
          {:error, {error, message}}
      end
    else
      error -> error
    end
  end

  defp validate_same_wallet(from_wallet, to_wallet) do
    if from_wallet.id == to_wallet.id do
      {:error, {:invalid, "Same wallet transfer not allowed"}}
    else
      :ok
    end
  end

  defp calculate_new_balance(wallet, amount, :withdraw) do Decimal.sub(wallet.balance, Decimal.new(Float.to_string(amount))) end
  defp calculate_new_balance(wallet, amount, :deposit) do Decimal.add(wallet.balance, Decimal.new(Float.to_string(amount))) end
  defp calculate_new_balance(wallet, amount, "deposit") do calculate_new_balance(wallet, amount, :deposit) end
  defp calculate_new_balance(wallet, amount, "withdraw") do calculate_new_balance(wallet, amount, :withdraw) end

  defp validate_sufficient_funds(new_balance) do
    if Decimal.compare(new_balance, Decimal.new("0.0")) == :lt do
      {:error, {:invalid, "Insufficient funds"}}
    else
      :ok
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

      Decimal.compare(Decimal.new(Float.to_string(amount)), Decimal.new("0.0")) in [:eq, :lt] ->
        {:error, {:invalid, "Amount must be greater than 0"}}

      true ->
        :ok
    end
  end
end
