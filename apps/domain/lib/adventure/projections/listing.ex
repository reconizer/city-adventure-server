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
    result = from(adventure in Models.Adventure,
      left_join: user_adventure in Models.UserAdventure, on: user_adventure.adventure_id == adventure.id and user_adventure.user_id == ^id,
      left_join: start_point in Models.Point, on: start_point.adventure_id == adventure.id and is_nil(start_point.parent_point_id),
      left_join: point in Models.Point, on: point.adventure_id == adventure.id,
      left_join: user_point in Models.UserPoint, on: user_point.point_id == point.id,
      select: %{
        adventure_id: adventure.id,
        start_point_id: start_point.id,
        started: not is_nil(user_adventure.adventure_id),
        completed: fragment("Coalesce(?, false)", user_adventure.completed),
        position: start_point.position,
        paid: false,
        purchased: false
      },
      where: adventure.show == true and adventure.published == true,
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), ?)::geography, ?::geography, ?)", ^lng, ^lat, ^srid, start_point.position, @distance),
      group_by: [adventure.id, start_point.id, user_adventure.adventure_id, user_adventure.completed]
    )
    |> Repository.all()
    {:ok, result}
  end

end
