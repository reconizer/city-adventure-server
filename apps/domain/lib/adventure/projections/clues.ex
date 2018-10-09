defmodule Domain.Adventure.Projections.Clues do
  @moduledoc """
  Projection clues for adventure
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :type, :description]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_discovered_clues_for_adventure(%{"adventure_id" => adventure_id, "current_user_id" => user_id}) do
    from(c in Models.Clue,
      join: p in Models.Point, on: [id: c.point_id],
      join: up in Models.UserPoint, on: [point_id: p.id],
      select: %{
        id: c.id,
        type: c.type,
        description: c.description,
        point_id: p.id 
      },
      where: up.user_id == ^user_id,
      where: p.adventure_id == ^adventure_id
    )
    |> Repository.all()
  end

  def get_clues_for_point(%{"adventure_id" => adventure_id, "point_id" => point_id}) do
    from(c in Models.Clue,
      join: p in Models.Point, on: [d: c.point_id],
      select: %{
        id: c.id,
        type: c.type,
        description: c.description,
        point_id: p.id 
      },
      where: p.id == ^point_id,
      where: p.adventure_id == ^adventure_id
    )
    |> Repository.one()
  end

end