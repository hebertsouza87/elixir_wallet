defmodule WalletWeb.WalletController.WalletJSON do
  def render(%Wallet.Wallet{} = wallet) do
    %{
      id: wallet.id,
      balance: Decimal.to_float(wallet.balance),
      user_id: wallet.user_id,
      number: wallet.number,
    }
  end
end
