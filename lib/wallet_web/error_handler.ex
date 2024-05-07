defmodule WalletWeb.ErrorHandler do
  @behaviour Plug

  import Plug.Conn

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    try do
      conn
    rescue
      e in NotFoundError ->
        response(conn, 404, e.message)
      e in _ ->
        Logger.error("Internal server error: #{inspect(e)}")
        response(conn, 500, e.message)
    end
  end

  defp response(conn, status, message) do
    conn
    |> put_status(status)
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(%{"status" => status, "error" => message}))
  end
end
