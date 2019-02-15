defmodule Domain.UserAdventure.EventHandlers.Adventure do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  import Ecto.Query

  alias Infrastructure.Repository

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "AdventureCompleted"} = event) do
    event.data
    |> case do
      %{
        completed: completed,
        user_id: user_id
      } ->
        user_adventure =
          from(user_adventure in Models.UserAdventure,
            where: user_adventure.adventure_id == ^event.aggregate_id,
            where: user_adventure.user_id == ^user_id
          )
          |> Repository.one()
          |> Models.UserAdventure.changeset(%{completed: completed})

        multi
        |> Ecto.Multi.update({event.id, event.name}, user_adventure)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "UserPointAdded"} = event) do
    event.data
    |> case do
      %{
        completed: completed,
        created_at: created_at,
        point_id: point_id,
        user_id: user_id
      } ->
        user_point =
          %Models.UserPoint{}
          |> Models.UserPoint.changeset(%{
            completed: completed,
            inserted_at: created_at,
            updated_at: created_at,
            point_id: point_id,
            user_id: user_id
          })

        multi
        |> Ecto.Multi.insert({event.id, user_id, point_id, event.name}, user_point)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "AdventureRatingCreated"} = event) do
    event.data
    |> case do
      %{
        rating: rating,
        created_at: created_at,
        adventure_id: adventure_id,
        user_id: user_id
      } ->
        adventure_rating =
          %Models.AdventureRating{}
          |> Models.AdventureRating.changeset(%{
            rating: rating,
            inserted_at: created_at,
            updated_at: created_at,
            adventure_id: adventure_id,
            user_id: user_id
          })

        multi
        |> Ecto.Multi.insert({event.id, user_id, adventure_id, event.name}, adventure_rating)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "UserAdventureAdded"} = event) do
    event.data
    |> case do
      %{
        completed: completed,
        created_at: created_at,
        adventure_id: adventure_id,
        user_id: user_id
      } ->
        user_adventure =
          %Models.UserAdventure{}
          |> Models.UserAdventure.changeset(%{
            completed: completed,
            inserted_at: created_at,
            updated_at: created_at,
            adventure_id: adventure_id,
            user_id: user_id
          })

        multi
        |> Ecto.Multi.insert({event.id, user_id, adventure_id, event.name}, user_adventure)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "RankingCreated"} = event) do
    event.data
    |> case do
      %{
        adventure_id: adventure_id,
        completion_time: completion_time,
        user_id: user_id
      } ->
        ranking =
          %Models.Ranking{}
          |> Models.Ranking.changeset(%{
            adventure_id: adventure_id,
            completion_time: completion_time,
            user_id: user_id
          })

        multi
        |> Ecto.Multi.insert({event.id, user_id, adventure_id, event.name}, ranking)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "UserPointUpdated"} = event) do
    event.data
    |> case do
      %{
        completed: completed,
        point_id: point_id,
        user_id: user_id,
        position: position
      } ->
        user_point =
          from(user_point in Models.UserPoint,
            where: user_point.user_id == ^user_id,
            where: user_point.point_id == ^point_id
          )
          |> Repository.one()
          |> Models.UserPoint.changeset(%{completed: completed, updated_at: NaiveDateTime.utc_now(), position: position})

        multi
        |> Ecto.Multi.update({event.id, user_id, point_id, event.name}, user_point)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "AdventureRatingUpdated"} = event) do
    event.data
    |> case do
      %{
        rating: rating,
        adventure_id: adventure_id,
        user_id: user_id
      } ->
        adventure_rating =
          from(adventure_rating in Models.AdventureRating,
            where: adventure_rating.user_id == ^user_id,
            where: adventure_rating.adventure_id == ^adventure_id
          )
          |> Repository.one()
          |> Models.AdventureRating.changeset(%{rating: rating, updated_at: NaiveDateTime.utc_now()})

        multi
        |> Ecto.Multi.update({event.id, user_id, adventure_id, event.name}, adventure_rating)

      _ ->
        multi
    end
  end
end
