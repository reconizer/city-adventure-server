defmodule Domain.Adventure.Projections.AdventureListing do
  @moduledoc """
  Projection of adventure start points
  """
  @distance 10000
  @type t :: %__MODULE__{}

  defstruct [:id, :description, :image_changed_at, :value, :available]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_start_points(%{"position" => %{lat: lat, lng: lng}}) do
    from(a in Models.Adventure,
      left_join: ua in Models.UserAdventure, on: [adventure_id: a.id],
      left_join: sp in Models.Point, on:  sp.adventure_id == a.id and is_nil(sp.parent_point_id),
      left_join: p in Models.Point, on: [adventure_id: a.id],
      left_join: up in Models.UserPoint, on: [point_id: p.id],
      where: a.show == true and a.published == true,
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), 4326)::geography, sp.position::geography, ?)", ^lat, ^lng, @distance)
    )
    |> Repository.all()
  end

end
