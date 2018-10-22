defmodule Seed.Adventure do
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Ecto.Multi
  
  def seed() do
    Multi.new()
    |> Multi.insert(:adventure, build_adventure(), returning: true)
  end

  defp build_adventure do
    %Models.Adventure{
      description: "opis",
      name: "śladami Kopernika",
      difficulty_level: 3,
      published: true,
      show: true,
      language: "PL",
      code: "1234",
      min_time: "03:00:00",
      max_time: "09:00:00"
    }
  end

  defp build_points(adventure_id) do
    osiolek = %{show: true,
      position: %Geo.Point{coordinates: {18.605192, 53.010279}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: nil,
      radius: 50,
      id: Ecto.UUID.generate(),
      clues: [
        %{

        }
      ]
    }
    fontanna = %{
      show: false,
      position: %Geo.Point{coordinates: {18.599850, 53.010747}, srid: 4326},
      adventure_id: adventure_id,
      radius: 50,
      parent_point_id: osiolek.id,
      clues: [
        %{

        }
      ]
    }
    filutek = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604505, 53.011100}, srid: 4326},
      adventure_id: adventure_id,
      radius: 200,
      parent_point_id: fontanna.id
    }
    smok = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608834, 53.010770}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: filutek.id
    }
    kura = %{
      show: false,
      position: %Geo.Point{coordinates: {18.60433, 53.01218}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: smok.id
    }
    kopernik = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604964, 53.010301}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: kura.id
    }
    brama = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608978, 53.008486}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: kopernik.id
    }
  end

end