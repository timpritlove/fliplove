defmodule Fliplove.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.debug("Starting Fliplove application...")

    children =
      [
        # Start the Telemetry supervisor
        FliploveWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Fliplove.PubSub},
        # Start core services first
        Fliplove.Font.Library,
        # Start hardware-related services first since they define display dimensions
        Fliplove.Driver,
        Fliplove.Display,
        # Start web-related services after display is ready
        FliploveWeb.VirtualDisplay,
        {FliploveWeb.Endpoint, []},
        # Start the Registry for apps
        {Registry, keys: :unique, name: Fliplove.Apps.Registry},
        # Start the dynamic supervisor for apps
        {DynamicSupervisor, strategy: :one_for_one, name: Fliplove.Apps.DynamicSupervisor},
        # Start the app manager and apps
        {Fliplove.Apps, []}
      ]

    Logger.debug("Starting optional services...")
    # Optional services that can be disabled
    optional_children =
      []
      |> maybe_start_megabitmeter()
      |> maybe_start_telegram_bot()

    # Use rest_for_one strategy to ensure services start in order and
    # if a service crashes, all services that depend on it are restarted
    opts = [strategy: :rest_for_one, name: Fliplove.Supervisor]

    Logger.debug(
      "Starting supervisor with #{length(children)} core services and #{length(optional_children)} optional services..."
    )

    result = Supervisor.start_link(children ++ optional_children, opts)
    Logger.debug("Supervisor started with result: #{inspect(result)}")

    # Clear the display before showing the welcome message
    Logger.debug("Clearing display...")
    Fliplove.Display.clear()

    # After all services have started, display the welcome message
    Logger.debug("Rendering welcome message...")
    render_welcome_message()

    result
  end

  defp maybe_start_megabitmeter(children) do
    case System.get_env("FLIPLOVE_MEGABITMETER_DEVICE") do
      nil ->
        Logger.warning("Megabitmeter disabled: FLIPLOVE_MEGABITMETER_DEVICE not set")
        children

      _device ->
        Logger.info("Megabitmeter enabled")
        [{Fliplove.Megabitmeter, []} | children]
    end
  end

  defp maybe_start_telegram_bot(children) do
    case System.get_env("FLIPLOVE_TELEGRAM_BOT_SECRET") do
      nil ->
        Logger.warning("Telegram bot disabled: FLIPLOVE_TELEGRAM_BOT_SECRET not set")
        children

      telegram_bot_secret ->
        Logger.info("Telegram bot enabled")
        [{Fliplove.TelegramBot, [bot_key: telegram_bot_secret]} | children]
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FliploveWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Render the welcome message on the display
  defp render_welcome_message do
    welcome_text = Application.fetch_env!(:fliplove, :display)[:welcome_text] || "Hello, World!"
    font = Fliplove.Font.Library.get_font_by_name("flipdot")

    Fliplove.Display.get()
    |> Fliplove.Font.Renderer.place_text(font, welcome_text, align: :center, valign: :middle)
    |> Fliplove.Display.set()
  end
end
