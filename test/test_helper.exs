ExUnit.start()

ExUnit.configure(exclude: [:db])

ExUnit.configure(exclude: [], include: [db: :test]) do
  Ecto.Adapters.SQL.Sandbox.start_link(Wallet.Repo, :sandbox)
end