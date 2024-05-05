defmodule WalletWeb.WalletController.TransferJSON do
  def render(%Wallet.Transaction{} = transfer) do
    %{
      id: transfer.id,
      amount: Decimal.to_float(transfer.amount),
      wallet_origin_number: transfer.wallet_origin_number,
      wallet_destination_number: transfer.wallet_destination_number,
      wallet_origin_id: transfer.wallet_origin_id,
      operation: transfer.operation
    }
  end
end
