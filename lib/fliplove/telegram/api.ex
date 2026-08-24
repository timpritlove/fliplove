defmodule Fliplove.Telegram.Api do
  @moduledoc """
  Minimal Telegram Bot API client using Req.

  All methods are called via HTTP POST with a JSON body, which covers both
  simple calls (getMe, getUpdates long polling) and methods with nested
  parameters such as sendMessage with an inline keyboard in reply_markup.
  """

  @base_url "https://api.telegram.org/bot"

  @doc """
  Calls a Telegram Bot API method.

  Returns `{:ok, result}` when the API responds with `"ok": true` (result is the "result" field).
  Returns `{:error, reason}` when the request fails or the API returns `"ok": false`.

  ## Examples

      request(token, "getMe")
      # => {:ok, %{"id" => 123, "username" => "MyBot", ...}}

      request(token, "getUpdates", offset: 0, timeout: 30)
      # => {:ok, [%{"update_id" => 1, ...}, ...]}
  """
  def request(token, method, params \\ []) do
    url(token, method)
    |> Req.post(json: Map.new(params), receive_timeout: 35_000)
    |> handle_response()
  end

  @doc """
  Sends a text message to a chat. Extra parameters (e.g. reply_markup) can be
  passed via `params`.
  """
  def send_message(token, chat_id, text, params \\ []) do
    request(token, "sendMessage", Map.merge(Map.new(params), %{chat_id: chat_id, text: text}))
  end

  @doc """
  Sends a photo from binary image data to a chat via multipart upload.
  Extra parameters (e.g. caption) can be passed via `params`.
  """
  def send_photo(token, chat_id, image, params \\ []) do
    fields =
      Map.new(params)
      |> Map.merge(%{
        chat_id: to_string(chat_id),
        photo: {image, filename: "screenshot.png", content_type: "image/png"}
      })

    url(token, "sendPhoto")
    |> Req.post(form_multipart: Map.to_list(fields), receive_timeout: 35_000)
    |> handle_response()
  end

  defp url(token, method), do: "#{@base_url}#{token}/#{method}"

  defp handle_response(response) do
    case response do
      {:ok, %{body: %{"ok" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %{body: %{"ok" => false, "description" => description}}} ->
        {:error, description}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end
end
