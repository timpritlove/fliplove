defmodule Fliplove.Telegram.Api do
  @moduledoc """
  Minimal Telegram Bot API client using Req.
  Replaces the external :telegram library for getMe and getUpdates (long polling).
  """

  @base_url "https://api.telegram.org/bot"

  @doc """
  Calls a Telegram Bot API method via GET.

  Returns `{:ok, result}` when the API responds with `"ok": true` (result is the "result" field).
  Returns `{:error, reason}` when the request fails or the API returns `"ok": false`.

  ## Examples

      request(token, "getMe")
      # => {:ok, %{"id" => 123, "username" => "MyBot", ...}}

      request(token, "getUpdates", offset: 0, timeout: 30)
      # => {:ok, [%{"update_id" => 1, ...}, ...]}
  """
  def request(token, method, opts \\ []) do
    url = "#{@base_url}#{token}/#{method}"

    case Req.get(url, params: opts, receive_timeout: 35_000) do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %{status: 200, body: %{"ok" => false, "description" => description}}} ->
        {:error, description}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end
end
