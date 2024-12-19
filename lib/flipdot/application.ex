defmodule Flipdot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        FlipdotWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Flipdot.PubSub},
        # Start the Endpoint (http/https)
        FlipdotWeb.Endpoint,
        # Start the Registry for apps
        {Registry, keys: :unique, name: Flipdot.App.Registry},
        # Start the DynamicSupervisor for apps
        {DynamicSupervisor, strategy: :one_for_one, name: Flipdot.App.DynamicSupervisor},
        # Start the App manager
        Flipdot.App,
        # Start other required services
        Flipdot.Display,
        Flipdot.Weather,
        Flipdot.Fluepdot,
        Flipdot.Font.Library
      ] ++
        case System.get_env("FLIPDOT_TELEGRAM_BOT_SECRET") do
          nil -> []
          telegram_bot_secret -> [{Flipdot.TelegramBot, bot_key: telegram_bot_secret}]
        end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flipdot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlipdotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
