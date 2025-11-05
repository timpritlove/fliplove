defmodule Fliplove.Location.Nominatim do
  @moduledoc """
  Helper module to resolve location names to coordinates using the Nominatim service.
  """

  require Logger

  @nominatim_url "https://nominatim.openstreetmap.org/search"

  @doc """
  Resolves a location name to coordinates using the Nominatim service.
  Returns {:ok, {lat, lon}} on success, {:error, reason} on failure.
  """
  def resolve_location(location) when is_binary(location) do
    params = [
      q: location,
      format: "json",
      limit: "1"
    ]

    headers = [{"user-agent", "Fliplove/1.0"}]

    case Req.get(@nominatim_url, params: params, headers: headers) do
      {:ok, %{status: 200, body: [%{"lat" => lat, "lon" => lon} | _]}} ->
        {lat_float, _} = Float.parse(lat)
        {lon_float, _} = Float.parse(lon)
        Logger.info("Resolved location '#{location}' to coordinates: #{lat_float}, #{lon_float}")
        {:ok, {lat_float, lon_float}}

      {:ok, %{status: 200, body: []}} ->
        {:error, :location_not_found}

      {:ok, %{status: status}} ->
        {:error, "HTTP error: #{status}"}

      {:error, exception} ->
        {:error, Exception.message(exception)}
    end
  end
end
