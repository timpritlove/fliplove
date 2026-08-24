defmodule Fliplove.TelegramBot do
  @moduledoc """
  Telegram bot connection. Use the FLIPLOVE_TELEGRAM_BOT_SECRET environment variable
  to pass a Telegram bot token to the application. The bot connects to Telegram,
  long-polls for updates and hands each update to Fliplove.Telegram.Handler, which
  implements the user-facing bot interface (text rendering, app control, menus).

  Every update is also announced via PubSub on `topic/0` so other modules can
  observe bot traffic.
  """
  use GenServer
  require Logger

  @topic "bot_update"
  @retry_delay_ms 5_000
  defstruct [:bot_key, :me, :last_seen]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl GenServer
  def init(opts) do
    {key, _opts} = Keyword.pop!(opts, :bot_key)

    case Fliplove.Telegram.Api.request(key, "getMe") do
      {:ok, me} ->
        Logger.info("Bot successfully self-identified: #{me["username"]}")

        Fliplove.Telegram.Handler.register_commands(key)

        state = %__MODULE__{
          bot_key: key,
          me: me,
          last_seen: -2
        }

        next_loop()

        {:ok, state}

      error ->
        Logger.error("Bot failed to self-identify: #{inspect(error)}")
        # Return :ignore to terminate this GenServer without crashing the supervisor
        :ignore
    end
  end

  @impl GenServer
  def handle_info(:check, %{bot_key: key, last_seen: last_seen} = state) do
    state =
      key
      |> Fliplove.Telegram.Api.request("getUpdates", offset: last_seen + 1, timeout: 30)
      |> case do
        # Empty, typically a timeout. State returned unchanged.
        {:ok, []} ->
          next_loop()
          state

        # A response with content, exciting!
        {:ok, updates} ->
          # Process our updates and return the latest update ID
          last_seen = handle_updates(key, updates, last_seen)

          # Update the last_seen state so we only get new updates on the
          # next check
          next_loop()
          %{state | last_seen: last_seen}

        {:error, reason} ->
          Logger.warning("Bot: Can't get updates: #{inspect(reason)} — retrying in #{@retry_delay_ms}ms")
          next_loop(@retry_delay_ms)
          state
      end

    {:noreply, state}
  end

  defp handle_updates(key, updates, last_seen) do
    updates
    # Process our updates
    |> Enum.map(fn update ->
      Logger.debug("Update received: #{inspect(update)}")

      dispatch(key, update)

      # Offload the updates to whoever they may concern
      broadcast(update)

      # Return the update ID so we can boil it down to a new last_seen
      update["update_id"]
    end)
    # Get the highest seen id from the new updates or fall back to last_seen
    |> Enum.max(fn -> last_seen end)
  end

  # A misbehaving handler must not take down the polling loop
  defp dispatch(key, update) do
    Fliplove.Telegram.Handler.handle_update(key, update)
  rescue
    e -> Logger.error("Bot: handler failed: #{Exception.message(e)}")
  catch
    :exit, reason -> Logger.error("Bot: handler exited: #{inspect(reason)}")
  end

  def topic, do: @topic

  defp broadcast(update) do
    # Send each update to a topic for others to listen to.
    Phoenix.PubSub.broadcast!(Fliplove.PubSub, @topic, {:bot_update, update})
  end

  defp next_loop(delay \\ 0) do
    Process.send_after(self(), :check, delay)
  end
end
