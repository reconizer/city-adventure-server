defmodule Domain.Profile.EventHandlers.CreatorFollower do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  alias Infrastructure.Repository

  import Ecto.Query

  def process(multi, %Domain.Event{aggregate_name: "Profile", name: "FollowCreator"} = event) do
    creator_follower = Models.CreatorFollower.build(event.data)

    multi
    |> Ecto.Multi.insert({event.id, event.name}, creator_follower)
  end

  def process(multi, %Domain.Event{aggregate_name: "Profile", name: "UnfollowCreator"} = event) do
    event.data
    |> case do
      %{
        creator_id: creator_id,
        user_id: user_id
      } ->
        creator_follower =
          from(follower in Models.CreatorFollower,
            where: follower.creator_id == ^creator_id,
            where: follower.user_id == ^user_id
          )

        multi
        |> Ecto.Multi.delete_all({event.id, event.name}, creator_follower)

      _ ->
        multi
    end
  end
end
