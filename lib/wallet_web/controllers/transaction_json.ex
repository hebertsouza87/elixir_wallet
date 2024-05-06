defmodule WalletWeb.WalletController.TransactionJSON do
  def render(%Wallet.Transaction{amount: amount} = transaction) do
    %{
      id: transaction.id,
      amount: convert_amount(amount),
      wallet_origin_number: transaction.wallet_origin_number,
      wallet_destination_number: transaction.wallet_destination_number,
      wallet_origin_id: transaction.wallet_origin_id,
      operation: transaction.operation
    }
  end

  defp convert_amount(amount) when is_float(amount), do: amount
  defp convert_amount(amount) when is_struct(amount, Decimal), do: Decimal.to_float(amount)
end
