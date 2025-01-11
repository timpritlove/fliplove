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
    query = URI.encode_query(%{
      q: location,
      format: "json",
      limit: "1"
    })

    url = "#{@nominatim_url}?#{query}"
    headers = [{"User-Agent", "Fliplove/1.0"}]

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, [%{"lat" => lat, "lon" => lon} | _]} ->
            {lat_float, _} = Float.parse(lat)
            {lon_float, _} = Float.parse(lon)
            Logger.info("Resolved location '#{location}' to coordinates: #{lat_float}, #{lon_float}")
            {:ok, {lat_float, lon_float}}
          {:ok, []} ->
            {:error, :location_not_found}
          {:error, _} = error ->
            error
        end
      {:ok, %{status_code: status}} ->
        {:error, "HTTP error: #{status}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
