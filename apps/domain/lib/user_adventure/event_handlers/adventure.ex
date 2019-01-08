defmodule Domain.UserAdventure.EventHandlers.Adventure do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  import Ecto.Query

  alias Infrastructure.Repository

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "AdventureCompleted"} = event) do
    event.data
    |> case do
      %{
        id: id,
        completed: completed
      } ->
        adventure =
          from(adventure in Models.Adventure,
            where: adventure.id == ^id
          )
          |> Repository.one()
          |> Models.Adventure.changeset(%{completed: completed})
        multi
        |> Ecto.Multi.update({event.id, event.name}, adventure)
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
      _ -> multi
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
      _ -> multi
    end
    
  end

  def process(multi, %Domain.Event{aggregate_name: "UserAdventure", name: "UserPointUpdated"} = event) do
    event.data
    |> case do
      %{
        completed: completed,
        point_id: point_id,
        user_id: user_id,
        position: position,
        inserted_at: inserted_at,
        updated_at: updated_at
      } -> 
        user_point = 
          %Models.UserPoint{point_id: point_id, 
            user_id: user_id, 
            position: position, 
            inserted_at: inserted_at, 
            updated_at: updated_at,
            completed: false
          }
          |> Models.UserPoint.changeset(%{completed: completed, updated_at: NaiveDateTime.utc_now()})
        multi
        |> Ecto.Multi.update({event.id, user_id, point_id, event.name}, user_point)
      _ -> multi
    end
    
  end

end