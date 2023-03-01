defmodule Flipdot.WeatherGenerator do
  @moduledoc """
  Generate weather info for display
  """
  use GenServer
  alias Flipdot.DisplayState
  require HTTPoison

  defstruct font: nil, timer: nil, api_key: nil, display_text: ""

  @font_file "data/fonts/x11/helvB12.bdf"
  @latitude 52.5363101
  @longitude 13.4273403
  @api_key "data/keys/openweathermap.txt"

  def start_link(_state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    font = FontRenderer.parse_font(@font_file)
    api_key = File.read!(@api_key)

    {:ok, %{state | font: font, api_key: api_key}}
  end

  def start_generator() do
    GenServer.call(__MODULE__, :start)
  end

  def stop_generator() do
    GenServer.call(__MODULE__, :stop)
  end

  # server functions

  @impl true
  def handle_call(:start, _, state) do
    {_, state} = update_weather(state)
    {:ok, timer} = :timer.send_interval(300_000, self(), :update_weather)
    {:reply, :ok, %{state | timer: timer}}
  end

  @impl true
  def handle_call(:stop, _, state) do
    if state.timer do
      {:ok, :cancel} = :timer.cancel(state.timer)
      {:reply, :ok, %{state | timer: nil}}
    else
      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_info(:update_weather, state) do
    update_weather(state)
  end

  def update_weather(state) do
    weather = get_weather(state.api_key)
    temp = weather["current"]["temp"]
    display_text = Float.to_string(temp) <> "°"

    if display_text != state.display_text do
      DisplayState.get() |> render_text(state.font, display_text) |> DisplayState.set()
    end

    {:noreply, %{state | display_text: display_text}}
  end

  def render_text(bitmap, font, text) do
    rendered_text =
      Bitmap.new(1000, 1000)
      |> FontRenderer.render_text(10, 10, font, text)
      |> Bitmap.clip()

    Bitmap.new(bitmap.meta.width, bitmap.meta.height)
    |> Bitmap.overlay(
      rendered_text,
      cursor_x: div(bitmap.meta.width - rendered_text.meta.width, 2),
      cursor_y: div(bitmap.meta.height - rendered_text.meta.height, 2)
    )
    |> Bitmap.overlay(Bitmap.frame(115, 16))
  end

  def get_weather(api_key) do
    url = "https://api.openweathermap.org/data/3.0/onecall"

    params = [
      {"lat", @latitude},
      {"lon", @longitude},
      {"units", "metric"},
      {"appid", api_key}
    ]

    case HTTPoison.get(url, [], params: params) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %{status_code: status_code}} ->
        raise("OpenWeatherMap API call failed (#{status_code})")
    end
  end
end
