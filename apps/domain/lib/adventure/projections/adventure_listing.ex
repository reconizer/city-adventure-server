defmodule Domain.Adventure.Projections.AdventureListing do
  @moduledoc """
  Projection of adventure start points
  """
  @distance 10000
  @type t :: %__MODULE__{}

  defstruct [:adventure_id, :start_point_id, :started, :completed, :position]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_start_points(%{"position" => %{lat: lat, lng: lng}, "current_user" => %{id: id}}) do
    from(a in Models.Adventure,
      left_join: ua in Models.UserAdventure, on: [adventure_id: a.id],
      left_join: sp in Models.Point, on:  sp.adventure_id == a.id and is_nil(sp.parent_point_id),
      left_join: p in Models.Point, on: [adventure_id: a.id],
      left_join: up in Models.UserPoint, on: [point_id: p.id],
      select: %{
        adventure_id: a.id,
        start_point_id: sp.id,
        started: not is_nil(ua.id),
        completed: ua.completed,
        position: sp.position
      },
      where: a.show == true and a.published == true,
      where: ua.user_id == ^id,
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), 4326)::geography, sp.position::geography, ?)", ^lat, ^lng, @distance)
    )
    |> Repository.all()
  end

end
