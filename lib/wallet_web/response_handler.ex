defmodule WalletWeb.ResponseHandler do
  import Plug.Conn
  import Phoenix.Controller

  alias Wallet.Wallet
  alias WalletWeb.WalletController.WalletJSON

  def render_response(conn, status, data) do
    conn
    |> put_status(status)
    |> json(data)
  end

  def handle_response({status, %Wallet{} = wallet}, conn) do
    render_response(conn, get_http_status(status), WalletJSON.render(wallet))
  end

  def handle_response({status, data}, conn) when is_map(data) do
    render_response(conn, get_http_status(status), data)
  end

  def handle_response({_, {status, message}}, conn) do
    render_response(conn, get_http_status(status), %{error: message})
  end

  def handle_response({status, message}, conn) do
    render_response(conn, get_http_status(status), %{error: message})
  end

  def handle_response({status, nil}, conn) do
    render_response(conn, get_http_status(status), %{error: get_error_message(status)})
  end

  defp get_http_status(:ok), do: :ok
  defp get_http_status(:created), do: :created
  defp get_http_status(:inivalid), do: :bad_request
  defp get_http_status(:not_found), do: :not_found
  defp get_http_status(_), do: :internal_server_error

  defp get_error_message(:invalid), do: "Invalid input"
  defp get_error_message(:not_found), do: "Not found"
  defp get_error_message(:error), do: "Internal server error"
  defp get_error_message(_), do: "Unknown error"

end
