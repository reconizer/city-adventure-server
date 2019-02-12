defmodule Domain.UserAdventure.Repository.Lisiting do
  @moduledoc """
  Repository listing adventure
  """
  use Infrastructure.Repository.Models
  use Domain.Repository
  import Ecto.Query
  alias Infrastructure.Repository
  alias Domain.UserAdventure.Listing

  @srid 4326
  @distance 10000

  def get_all(%{user_id: id, position: %{lat: lat, lng: lng}}) do
    result =
      from(adventure in Models.Adventure,
        left_join: user_adventure in Models.UserAdventure,
        on: user_adventure.adventure_id == adventure.id and user_adventure.user_id == ^id,
        left_join: start_point in Models.Point,
        on: start_point.adventure_id == adventure.id and is_nil(start_point.parent_point_id),
        left_join: point in Models.Point,
        on: point.adventure_id == adventure.id,
        left_join: user_point in Models.UserPoint,
        on: user_point.point_id == point.id,
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
        where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), ?)::geography, ?::geography, ?)", ^lng, ^lat, ^@srid, start_point.position, @distance),
        group_by: [adventure.id, start_point.id, user_adventure.adventure_id, user_adventure.completed]
      )
      |> Repository.all()
      |> Enum.map(&load_adventure/1)

    {:ok, result}
  end

  defp load_adventure(adventure_model) do
    %Listing{
      id: adventure_model.adventure_id,
      start_point_id: adventure_model.start_point_id,
      started: adventure_model.started,
      completed: adventure_model.completed,
      position: adventure_model.position,
      paid: adventure_model.paid,
      purchased: adventure_model.purchased
    }
  end
end
