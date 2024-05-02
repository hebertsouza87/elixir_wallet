defmodule Wallet.ConfigAgent do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_jwt_secret_key() do
    get_env("JWT_SECRET_KEY", "secret_key")
  end

  defp get_env(var, default) do
    Agent.get_and_update(__MODULE__, fn state ->
      case Map.fetch(state, var) do
        {:ok, value} -> {value, state}
        :error ->
          value = System.get_env(var) || default
          {value, Map.put(state, var, value)}
      end
    end)
  end
end
