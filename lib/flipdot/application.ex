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
        # Start core services first
        Flipdot.Font.Library,
        Flipdot.Display,
        # Start the Registry for apps
        {Registry, keys: :unique, name: Flipdot.App.Registry},
        # Start the DynamicSupervisor for apps
        {DynamicSupervisor, strategy: :one_for_one, name: Flipdot.App.DynamicSupervisor},
        # Start services that depend on core services
        {Flipdot.App, []},
        {Flipdot.Weather, []},
        {Flipdot.Fluepdot, []},
        # Start the Endpoint last (after all services are ready)
        {FlipdotWeb.Endpoint, []}
      ] ++
        case System.get_env("FLIPDOT_TELEGRAM_BOT_SECRET") do
          nil -> []
          telegram_bot_secret -> [{Flipdot.TelegramBot, bot_key: telegram_bot_secret}]
        end

    # Use rest_for_one strategy to ensure services start in order and
    # if a service crashes, all services that depend on it are restarted
    opts = [strategy: :rest_for_one, name: Flipdot.Supervisor]
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
