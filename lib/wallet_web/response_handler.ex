defmodule WalletWeb.ResponseHandler do
  import Plug.Conn
  import Phoenix.Controller

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

  def handle_response({:ok, data}, status, conn), do: send_resp(conn, status, data)

  def handle_response({:error, reason}, _status, conn), do: send_resp(conn, 400, reason)

  def handle_response({:not_found, reason}, _status, conn), do: render_response(conn, :not_found, %{error: reason})

  def handle_response({:error, _reason}, _status, conn) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "An unexpected error occurred"})
  end

  def handle_response(%Transaction{} = transaction, status, conn) do
    render_response(conn, get_http_status(status), TransactionJSON.render(transaction))
  end

  def handle_response({status, {:ok, %Wallet{} = wallet}}, conn) do
    render_response(conn, get_http_status(status), WalletJSON.render(wallet))
  end

  def handle_response({status, %Transaction{} = transaction}, conn) do
    render_response(conn, get_http_status(status), TransactionJSON.render(transaction))
  end

  def handle_response({status, data}, conn) when is_map(data) do
    render_response(conn, get_http_status(status), data)
  end

  def handle_response({_, {status, message}}, conn) do
    render_response(conn, get_http_status(status), %{error: message})
  end

  def handle_response({status, nil}, conn) do
    render_response(conn, get_http_status(status), %{error: get_error_message(status)})
  end

  def handle_response({status, ""}, conn) do
    render_response(conn, get_http_status(status), %{error: get_error_message(status)})
  end

  def handle_response({status, message}, conn) do
    render_response(conn, get_http_status(status), %{error: message})
  end

  defp get_error_data( message), do: %{error: message}

  defp get_http_status(:ok), do: :ok
  defp get_http_status(:created), do: :created
  defp get_http_status(:invalid), do: :bad_request
  defp get_http_status(:not_found), do: :not_found
  defp get_http_status(_), do: :internal_server_error

  defp get_error_message(:invalid), do: "Invalid input"
  defp get_error_message(:not_found), do: "Not found"
  defp get_error_message(:error), do: "Internal server error"
  defp get_error_message(_), do: "Unknown error"

end
