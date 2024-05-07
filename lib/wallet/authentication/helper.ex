defmodule Authentication.Helper do
  @moduledoc """
  Módulo de ajuda para autenticação.
  """

  alias Joken
  alias Joken.Signer
  alias Wallet.ConfigAgent

  @algorithm "HS256"

  @doc """
  Extrai o user_id do cabeçalho de autorização da conexão.

  ## Exemplos

      iex> get_user_id_from_conn(conn)
      {:ok, "user_id"}

  """
  def get_user_id_from_conn(conn) do
    with [auth_header | _] <- Plug.Conn.get_req_header(conn, "authorization"),
         [_, jwt | _] <- String.split(auth_header),
         {:ok, claims} <- Joken.verify(jwt, create_signer(), []),
         user_id when is_binary(user_id) <- claims |> Map.get("user_id") do
      {:ok, user_id}
    else
      _ -> {:error, "Failed to get user_id from conn"}
    end
  end

  def get_user_id_from_conn!(conn) do
    with {:ok, user_id} <- get_user_id_from_conn(conn) do
      user_id
    else
      _ -> raise "Failed to get user_id from conn"
    end
  end

  @doc """
  Cria um token JWT para o user_id fornecido.
  Em uma aplicação real, essa funcão não deveria existir aqui, a criacão do token deve ser responsabilidade
  de outra aplicacão. Outra aplicacão ser capaz de criar tokens JWT validos é uma falha de seguranca.

  ## Exemplos

      iex> create_token("user_id")
      {:ok, "jwt_token"}

  """
  def create_token(user_id) do
    claims = %{"user_id" => user_id}
    Joken.encode_and_sign(claims, create_signer())
  end

  @doc false
  defp create_signer do
    secret_key = ConfigAgent.get_jwt_secret_key()
    Signer.create(@algorithm, secret_key)
  end
end
