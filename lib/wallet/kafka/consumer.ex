defmodule Wallet.Kafka.Consumer do
  require Logger
  alias Wallet.Transactions

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_messages(messages) do
    for %{key: key, value: value} <- messages do
      handle_message(key, value)
    end
    :ok
  end

  def handle_message("deposit", value) do
    Logger.info("Processing deposit: " <> value)
    json = value
    |> Jason.decode!()
    transaction = Transactions.register_transaction(json)
    :telemetry.execute([:kafka, :deposit, :consumer], %{id: json["id"]})
    transaction
  end

  def handle_message(key, message) do
    Logger.error("Message not expected: " <> key <> " - " <> message)
    :error
  end
end
