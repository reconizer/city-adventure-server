defmodule Domain.Adventure.Projections.Adventure do
  @moduledoc """
  Projection of adventure information
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :description, :estimated_time, :difficulty_level, :language]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_adventure_id(adventure_id) do
    from(a in Models.Adventure,
      left_join: ua in Models.UserAdventure, on: [adventure_id: a.id],
      left_join: sp in Models.Point, on:  sp.adventure_id == a.id and is_nil(sp.parent_point_id),
      left_join: p in Models.Point, on: [adventure_id: a.id],
      left_join: up in Models.UserPoint, on: [point_id: p.id],
      select: %{
        id: a.id,
        description: a.description,
        name: a.name,
        estimated_time: a.estimated_time,
        difficulty_level: a.difficulty_level,
        language: a.language
      },
      where: a.published == true,
      where: a.id == ^adventure_id
    )
    |> Repository.one()
  end

end