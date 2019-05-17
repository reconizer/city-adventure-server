defmodule Domain.Profile.EventHandlers.CreatorFollower do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  def process(multi, %Domain.Event{aggregate_name: "Profile.CreatorProfile", name: "Follow"} = event) do
    creator_follower = Models.CreatorFollower.build(event.data)

    multi
    |> Ecto.Multi.insert({event.id, event.name}, creator_follower)
  end

  def process(multi, %Domain.Event{aggregate_name: "Profile.CreatorProfile", name: "Unfollow"} = event) do
    event.data
    |> case do
      %{
        creator_id: creator_id,
        user_id: user_id
      } ->
        creator_follower =
          from(creator_follower in Models.CreatorFollower,
            where: creator_follower.creator_id == ^creator_id,
            where: creator_follower.user_id == ^user_id
          )
          |> Repository.one()

        multi
        |> Ecto.Multi.delete({event.id, event.name}, creator_follower)

      _ ->
        multi
    end
  end
end
