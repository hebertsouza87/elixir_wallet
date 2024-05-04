defmodule WalletWeb.ErrorHandler do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    try do
      conn
    rescue
      e in _ ->
        send_resp(conn, 500, "Internal server error: #{Exception.message(e)}")
    end
  end
end
