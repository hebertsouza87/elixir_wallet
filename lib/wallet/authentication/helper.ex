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
    conn
    |> Plug.Conn.get_req_header("authorization")
    |> List.first()
    |> String.split()
    |> get_jwt()
    |> Joken.verify(create_signer(), [])
    |> get_user_id_from_claims()
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
    %{"user_id" => user_id}
    |> Joken.encode_and_sign(create_signer())
  end

  @doc false
  defp create_signer do
    Signer.create(@algorithm, ConfigAgent.get_jwt_secret_key())
  end

  defp get_jwt([_, jwt | _]), do: jwt
  defp get_jwt(_), do: {:unauthorized, "Failed to get jwt from auth_header"}

  defp get_user_id_from_claims({:ok, claims}) do
    claims
    |> Map.get("user_id")
    |> check_user_id()
  end
  defp get_user_id_from_claims(_), do: {:unauthorized, "Failed to get user_id from conn"}

  defp check_user_id(user_id) when is_binary(user_id), do: {:ok, user_id}
  defp check_user_id(_), do: {:unauthorized, "Failed to get user_id from conn"}
end
