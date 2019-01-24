defmodule Contract.Position do
  def position_cast(%{"position" => %{lat: nil, lng: nil}} = params) do
    params
    |> Map.put("position", nil)
  end

  def position_cast(%{"position" => %{lat: lat, lng: lng}} = params) do
    {lat, lng} = parse({lat, lng})

    params
    |> Map.put("position", %Geo.Point{coordinates: {lng, lat}, srid: 4326})
  end

  def position_cast(%{"position" => %{"lat" => lat, "lng" => lng}} = params) do
    {lat, lng} = parse({lat, lng})

    params
    |> Map.put("position", %Geo.Point{coordinates: {lng, lat}, srid: 4326})
  end

  def position_cast(params) do
    params
  end

  defp parse({lat, lng}) do
    lat =
      cond do
        is_bitstring(lat) -> String.to_float(lat)
        true -> lat
      end

    lng =
      cond do
        is_bitstring(lng) -> String.to_float(lng)
        true -> lng
      end

    {lat, lng}
  end
end
