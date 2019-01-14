defmodule Contract.Position do

  def position_cast(%{"position" => %{lat: nil, lng: nil}} = params) do
    params
    |> Map.put("position", nil)
  end

  def position_cast(%{"position" => %{lat: lat, lng: lng}} = params) do
    params
    |> Map.put("position", %Geo.Point{coordinates: {String.to_float(lng), String.to_float(lat)}, srid: 4326})
  end

  def position_cast(%{"position" => %{"lat" => lat, "lng" => lng}} = params) do
    params
    |> Map.put("position", %Geo.Point{coordinates: {String.to_float(lng), String.to_float(lat)}, srid: 4326})
  end
  
  def position_cast(params) do
    params
  end  

end