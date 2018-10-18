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
    %{show: false,
      position: %{},
      adventure_id: adventure_id,
      parent_point_id: nil,
      radius: 200
    }
  end

end