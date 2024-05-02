defmodule WalletWeb.HelloController do
  use WalletWeb, :controller

  def hello(conn, _params) do
    json(conn, %{message: "Hello World"})
  end
end