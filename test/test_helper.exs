ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Wallet.Repo, {:shared, self()})

try do
  Mix.Tasks.Ecto.Drop.run([])
rescue
  _ -> IO.puts("---------- Aviso: Falha ao deletar o banco de testes. ------------")
end

Mix.Tasks.Ecto.Create.run([])
Mix.Tasks.Ecto.Migrate.run([])
