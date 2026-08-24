defmodule Fliplove.Telegram.Handler do
  @moduledoc """
  User interface of the Telegram bot.

  Plain text messages are rendered on the display with the system's default
  font, the same way the web interface renders text. Commands provide a simple
  menu-driven interface to control the display:

  - /help — usage overview
  - /apps — inline keyboard to start or stop apps
  - /stop — stop the running app
  - /clear — clear the display
  - /screenshot — send a picture of the current display content
  - /status — show display size and running app
  - /text <text> — render text that would otherwise be parsed as a command

  Access can be restricted with the FLIPLOVE_TELEGRAM_ALLOWED_USERS environment
  variable (comma-separated Telegram usernames or numeric user IDs). When it is
  unset, anyone who finds the bot may use it.
  """

  alias Fliplove.Apps
  alias Fliplove.Bitmap
  alias Fliplove.Display
  alias Fliplove.Font.Library
  alias Fliplove.Font.Renderer
  alias Fliplove.Telegram.Api

  require Logger

  @default_font "flipdot"

  @commands [
    %{command: "apps", description: "Start or stop apps"},
    %{command: "stop", description: "Stop the running app"},
    %{command: "clear", description: "Clear the display"},
    %{command: "screenshot", description: "Send a picture of the display"},
    %{command: "status", description: "Show display status"},
    %{command: "text", description: "Render text on the display"},
    %{command: "help", description: "How to use this bot"}
  ]

  @help_text """
  This bot controls a flipdot display.

  Send me any text and I will render it on the display.

  Commands:
  /apps — choose an app to run on the display
  /stop — stop the running app
  /clear — clear the display
  /screenshot — send a picture of the current display content
  /status — show display size and running app
  /text <text> — render text that starts with a "/"
  /help — show this message
  """

  @doc """
  Registers the bot's command list with Telegram so clients offer the "/" menu.
  """
  def register_commands(key) do
    case Api.request(key, "setMyCommands", commands: @commands) do
      {:ok, _} -> :ok
      {:error, reason} -> Logger.warning("Telegram: failed to register bot commands: #{inspect(reason)}")
    end
  end

  @doc """
  Handles a single update from the Telegram getUpdates long poll.
  """
  def handle_update(key, %{"message" => %{"text" => text} = message}) when is_binary(text) do
    chat_id = message["chat"]["id"]
    from = message["from"]

    text = String.trim(text)

    if authorized?(from) do
      Logger.info("Telegram bot: #{describe_user(from)} sent #{describe_input(text)}")
      handle_text(key, chat_id, text)
    else
      Logger.warning("Telegram bot: unauthorized message from #{describe_user(from)}")
      Api.send_message(key, chat_id, "⛔ Sorry, you are not authorized to use this bot.")
    end
  end

  def handle_update(key, %{"callback_query" => %{"id" => query_id} = query}) do
    from = query["from"]

    if authorized?(from) do
      Logger.info("Telegram bot: #{describe_user(from)} pressed menu button #{inspect(query["data"])}")
      handle_callback(key, query)
    else
      Logger.warning("Telegram bot: unauthorized menu button press from #{describe_user(from)}")
      Api.request(key, "answerCallbackQuery", callback_query_id: query_id, text: "Not authorized")
    end
  end

  def handle_update(_key, update) do
    Logger.debug("Telegram: ignoring update: #{inspect(update)}")
  end

  # Commands start with a slash; anything else goes straight to the display.

  defp handle_text(key, chat_id, "/" <> _ = text) do
    {command, args} =
      case String.split(text, ~r/\s+/, parts: 2) do
        [command] -> {command, ""}
        [command, args] -> {command, args}
      end

    # Strip an optional @BotName suffix as used in group chats
    command = command |> String.split("@") |> hd()

    handle_command(key, chat_id, command, args)
  end

  defp handle_text(key, chat_id, text), do: render_text(key, chat_id, text)

  defp handle_command(key, chat_id, start_or_help, _args) when start_or_help in ["/start", "/help"] do
    Api.send_message(key, chat_id, @help_text)
  end

  defp handle_command(key, chat_id, "/apps", _args) do
    running = Apps.running_app()

    app_buttons =
      for app <- Apps.available_apps() do
        label = if app == running, do: "▶️ #{app}", else: to_string(app)
        %{text: label, callback_data: "app:#{app}"}
      end

    keyboard = Enum.chunk_every(app_buttons, 2) ++ [[%{text: "⏹ Stop running app", callback_data: "app:stop"}]]

    Api.send_message(key, chat_id, "Which app should run on the display?", reply_markup: %{inline_keyboard: keyboard})
  end

  defp handle_command(key, chat_id, "/stop", _args) do
    Api.send_message(key, chat_id, stop_running_app())
  end

  defp handle_command(key, chat_id, "/clear", _args) do
    Display.clear()
    Api.send_message(key, chat_id, "🧹 Display cleared." <> running_app_note())
  end

  defp handle_command(key, chat_id, "/screenshot", _args) do
    png = Fliplove.Screenshot.render(Display.get())

    case Api.send_photo(key, chat_id, png) do
      {:ok, _} ->
        :ok

      {:error, reason} ->
        Logger.warning("Telegram: sending screenshot failed: #{inspect(reason)}")
        Api.send_message(key, chat_id, "❌ Could not send a screenshot.")
    end
  end

  defp handle_command(key, chat_id, "/status", _args) do
    app = Apps.running_app() || "none"

    Api.send_message(
      key,
      chat_id,
      "Display: #{Display.width()}×#{Display.height()} pixels\nRunning app: #{app}"
    )
  end

  defp handle_command(key, chat_id, "/text", ""), do: Api.send_message(key, chat_id, "Usage: /text <text>")
  defp handle_command(key, chat_id, "/text", args), do: render_text(key, chat_id, args)

  defp handle_command(key, chat_id, command, _args) do
    Api.send_message(key, chat_id, "Unknown command #{command}. Try /help.")
  end

  defp render_text(key, chat_id, text) do
    font = Library.get_font_by_name(@default_font)

    Bitmap.new(Display.width(), Display.height())
    |> Renderer.place_text(font, text, align: :center, valign: :middle)
    |> Display.set()

    Api.send_message(key, chat_id, "✅ Text is on the display." <> running_app_note())
  end

  defp running_app_note do
    case Apps.running_app() do
      nil -> ""
      app -> "\n⚠️ The #{app} app is still running and may repaint the display. Use /stop to stop it."
    end
  end

  defp handle_callback(key, %{"id" => query_id, "data" => "app:" <> action, "message" => message}) do
    feedback =
      case action do
        "stop" ->
          stop_running_app()

        app_name ->
          case Enum.find(Apps.available_apps(), &(to_string(&1) == app_name)) do
            nil -> "Unknown app #{app_name}."
            app -> start_app(app)
          end
      end

    Api.request(key, "answerCallbackQuery", callback_query_id: query_id)

    # Replace the menu with the outcome so the chat reflects what happened
    Api.request(key, "editMessageText",
      chat_id: message["chat"]["id"],
      message_id: message["message_id"],
      text: feedback
    )
  end

  defp handle_callback(key, %{"id" => query_id}) do
    Api.request(key, "answerCallbackQuery", callback_query_id: query_id)
  end

  defp start_app(app) do
    case Apps.start_app(app) do
      :ok -> "▶️ Started #{app}."
      {:ok, :app_already_running} -> "#{app} is already running."
      {:error, _reason} -> "❌ Failed to start #{app}."
    end
  end

  defp stop_running_app do
    case Apps.running_app() do
      nil ->
        "No app is running."

      app ->
        Apps.stop_app()
        "⏹ Stopped #{app}."
    end
  end

  # "Tim Pritlove (@tim, id 12345)" — Telegram includes the sender in every update,
  # so no lookup is needed. The username is optional and may be absent.
  defp describe_user(from) do
    name =
      [from["first_name"], from["last_name"]]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    handle = if from["username"], do: "@#{from["username"]}, ", else: ""

    "#{name} (#{handle}id #{from["id"]})"
  end

  defp describe_input("/" <> _ = command), do: "command #{command}"
  defp describe_input(text), do: "text #{inspect(text)}"

  defp authorized?(from) do
    case allowed_users() do
      nil ->
        true

      allowed ->
        username = String.downcase(from["username"] || "")
        id = to_string(from["id"])
        username in allowed or id in allowed
    end
  end

  @doc """
  Returns the list of allowed usernames/user IDs from FLIPLOVE_TELEGRAM_ALLOWED_USERS,
  or nil when access is not restricted.
  """
  def allowed_users do
    with value when is_binary(value) <- System.get_env("FLIPLOVE_TELEGRAM_ALLOWED_USERS"),
         [_ | _] = users <-
           value
           |> String.split(",")
           |> Enum.map(&(&1 |> String.trim() |> String.trim_leading("@") |> String.downcase()))
           |> Enum.reject(&(&1 == "")) do
      users
    else
      _ -> nil
    end
  end
end
