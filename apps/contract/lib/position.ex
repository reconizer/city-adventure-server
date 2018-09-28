defmodule Contract.Position do

  def position_cast(%{"position" => %{lat: lat, lng: lng}} = params) do
    params
    |> Map.put("position", %Geo.Point{coordinates: {lng, lat}, srid: 4326})
  end  
end