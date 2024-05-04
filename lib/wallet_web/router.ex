defmodule WalletWeb.Router do
  use WalletWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug WalletWeb.ErrorHandler
  end

  scope "/api", WalletWeb do
    pipe_through :api

    post "/wallets", WalletController, :create

    post "/deposit", TransactionController, :deposit
    post "/withdraw", TransactionController, :withdraw
    post "/transfer", TransactionController, :transfer

    if Mix.env() == :dev do
      scope "/dev" do
        post "/token", DevAuxController, :create_token
      end
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:wallet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: WalletWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
