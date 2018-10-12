defmodule Domain.Adventure.Projections.Listing do
  @moduledoc """
  Projection of adventure start points
  """
  @distance 10000
  @type t :: %__MODULE__{}

  defstruct [:adventure_id, :start_point_id, :started, :completed, :position]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_start_points(%{position: %Geo.Point{coordinates: {lng, lat}, srid: srid}}, %{id: id}) do
    result = from(a in Models.Adventure,
      left_join: ua in Models.UserAdventure, on: ua.adventure_id == a.id and ua.user_id == ^id,
      left_join: sp in Models.Point, on: sp.adventure_id == a.id and is_nil(sp.parent_point_id),
      left_join: p in Models.Point, on: p.adventure_id == a.id,
      left_join: up in Models.UserPoint, on: up.point_id == p.id,
      select: %{
        adventure_id: a.id,
        start_point_id: sp.id,
        started: not is_nil(ua.user_id),
        completed: not is_nil(ua.completed),
        position: sp.position,
        paid: false
      },
      where: a.show == true and a.published == true,
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), ?)::geography, ?::geography, ?)", ^lng, ^lat, ^srid, sp.position, @distance)
    )
    |> Repository.all()
    {:ok, result}
  end

end
