defmodule WalletWeb.ResponseHandler do
  import Plug.Conn
  import Phoenix.Controller

  require Logger

  alias Wallet.Transaction
  alias Wallet.Wallet
  alias WalletWeb.WalletController.WalletJSON
  alias WalletWeb.WalletController.TransactionJSON

  def render_response(conn, status, data) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> put_status(status)
    |> json(data)
  end

  def handle_response({:error, %Ecto.Changeset{} = changeset}, _http_status, conn) do
    [first_error | _] = changeset.errors
    {field, {message, _}} = first_error
    render_response(conn, :bad_request, %{error: Atom.to_string(field) <> " " <> message})
  end

  def handle_response({_, %Wallet{} = wallet}, http_status, conn) do
    render_response(conn, http_status, WalletJSON.render(wallet))
  end

  def handle_response({_status, %Transaction{} = transaction}, http_status, conn) do
    render_response(conn, http_status, TransactionJSON.render(transaction))
  end

  def handle_response({:unauthorized, reason}, _status, conn), do: render_response(conn, :unauthorized, %{error: reason})
  def handle_response({:error, reason}, _status, conn) do
    Logger.error("Not treated error: #{inspect(reason)}")
    render_response(conn, :internal_server_error, %{error: reason})
  end
  def handle_response({:not_found, reason}, _status, conn), do: render_response(conn, :not_found, %{error: reason})
  def handle_response({:bad_request, reason}, _status, conn), do: render_response(conn, :bad_request, %{error: reason})

  def handle_response({status, %Wallet{} = wallet}, conn) do
    render_response(conn, status, WalletJSON.render(wallet))
  end

  def handle_response({status, %Transaction{} = transaction}, conn) do
    render_response(conn, status, TransactionJSON.render(transaction))
  end

  def handle_response({status, data}, conn) when is_map(data) do
    render_response(conn, status, data)
  end

  def handle_response({status, message}, conn) when is_binary(message) do
    render_response(conn, status, %{error: message})
  end
end
