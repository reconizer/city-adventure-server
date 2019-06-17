defmodule Domain.Profile.EventHandlers.Profile do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  alias Infrastructure.Repository

  import Ecto.Query

  def process(multi, %Domain.Event{aggregate_name: "Profile", name: "NickChanged"} = event) do
    user =
      Models.User
      |> Repository.get(event.aggregate_id)
      |> Models.User.changeset(event.data)

    multi
    |> Ecto.Multi.update({event.id, event.name}, user)
  end

  def process(multi, %Domain.Event{aggregate_name: "Profile", name: "AvatarChanged"} = event) do
    avatar =
      from(avatar in Models.Avatar,
        where: avatar.user_id == ^event.data.user_id
      )
      |> Repository.one()
      |> Models.Avatar.changeset(%{asset_id: event.data.asset_id})

    multi
    |> Ecto.Multi.update({event.id, event.name}, avatar)
  end
end
