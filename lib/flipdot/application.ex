defmodule Flipdot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Bitmap

  @impl true
  def start(_type, _args) do
    space_invaders =
      defbitmap([
        "                                                                                                                   ",
        "                                                                                                                   ",
        "                                                                                                                   ",
        "                                                                                                                   ",
        "           X     X           X     X            XX             XX              XXXX               XXXX             ",
        "            X   X          X  X   X  X         XXXX           XXXX          XXXXXXXXXX         XXXXXXXXXX          ",
        "           XXXXXXX         X XXXXXXX X        XXXXXX         XXXXXX        XXXXXXXXXXXX       XXXXXXXXXXXX         ",
        "          XX XXX XX        XXX XXX XXX       XX XX XX       XX XX XX       XXX  XX  XXX       XXX  XX  XXX         ",
        "         XXXXXXXXXXX       XXXXXXXXXXX       XXXXXXXX       XXXXXXXX       XXXXXXXXXXXX       XXXXXXXXXXXX         ",
        "         X XXXXXXX X        XXXXXXXXX          X  X          X XX X           XX  XX            XXX  XXX           ",
        "         X X     X X         X     X          X XX X        X      X         XX XX XX          XX  XX  XX          ",
        "            XX XX           X       X        X X  X X        X    X        XX        XX         XX    XX           ",
        "                                                                                                                   ",
        "                                                                                                                   ",
        "                                                                                                                   ",
        "                                                                                                                   "
      ])

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
      {Flipdot.DisplayState, space_invaders},
      Flipdot.ClockGenerator,
      Flipdot.WeatherGenerator,
      Flipdot.DisplayPusher
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
