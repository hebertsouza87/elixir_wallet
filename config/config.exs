# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :logger, level: :debug

config :wallet,
  ecto_repos: [Wallet.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :wallet, WalletWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: WalletWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Wallet.PubSub,
  live_view: [signing_salt: "1xrcPAdv"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :wallet, Wallet.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  wallet: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  wallet: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Config Kafka
config :kaffe,
  consumer: [
    endpoints: [{String.to_atom(System.get_env("KAFKA_HOST", "localhost")), String.to_integer(System.get_env("KAFKA_PORT", "9092"))}],
    topics: String.split(System.get_env("KAFKA_CONSUMER_TOPICS", "FinancialTransactions"), ",", trim: true),
    consumer_group: System.get_env("KAFKA_CONSUMER_GROUP", "wallet_api"),
    message_handler: Wallet.Kafka.Consumer
  ],
  producer: [
    endpoints: [{String.to_atom(System.get_env("KAFKA_HOST", "localhost")), String.to_integer(System.get_env("KAFKA_PORT", "9092"))}],
    default_topic: System.get_env("KAFKA_DEFAULT_TOPIC", "FinancialTransactions"),
    topics: String.split(System.get_env("KAFKA_PRODUCER_TOPICS", "FinancialTransactions"), ",", trim: true)
  ]

config :wallet, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: WalletWeb.Router,
      endpoint: WalletWeb.Endpoint
    ]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
