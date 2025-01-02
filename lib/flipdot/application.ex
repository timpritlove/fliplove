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
        # Start hardware-related services first since they define display dimensions
        {Flipdot.Driver, []},
        Flipdot.Display,
        # Start web-related services after display is ready
        FlipdotWeb.VirtualDisplay,
        {FlipdotWeb.Endpoint, []},
        # Start the Registry for apps
        {Registry, keys: :unique, name: Flipdot.Apps.Registry},
        # Start the dynamic supervisor for apps
        {DynamicSupervisor, strategy: :one_for_one, name: Flipdot.Apps.DynamicSupervisor},
        # Start the app manager and apps
        {Flipdot.Apps, []},
        {Flipdot.Weather, []},
        {Flipdot.Megabitmeter, []}
      ] ++
        case System.get_env("FLIPDOT_TELEGRAM_BOT_SECRET") do
          nil -> []
          telegram_bot_secret -> [{Flipdot.TelegramBot, bot_key: telegram_bot_secret}]
        end

    # Use rest_for_one strategy to ensure services start in order and
    # if a service crashes, all services that depend on it are restarted
    opts = [strategy: :rest_for_one, name: Flipdot.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Clear the display before showing the welcome message
    Flipdot.Display.clear()

    # After all services have started, display the welcome message
    render_welcome_message()

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlipdotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Render the welcome message on the display
  defp render_welcome_message do
    welcome_text = Application.fetch_env!(:flipdot, :display)[:welcome_text] || "Hello, World!"
    font = Flipdot.Font.Library.get_font_by_name("flipdot")

    Flipdot.Display.get()
    |> Flipdot.Font.Renderer.place_text(font, welcome_text, align: :center, valign: :middle)
    |> Flipdot.Display.set()
  end
end
