defmodule Flipdot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FlipdotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Flipdot.PubSub},
      # Start Finch
      {Finch, name: Flipdot.Finch},
      # Start the Endpoint (http/https)
      FlipdotWeb.Endpoint,
      # Start a worker by calling: Flipdot.Worker.start_link(arg)
      # {Flipdot.Worker, arg}
      {Flipdot.DisplayState, Flipdot.Images.images()["space-invaders"]},
      Flipdot.Weather,
      Flipdot.DisplayPusher,
      Flipdot.Font.Library,
      Flipdot.Dashboard
    ]

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
