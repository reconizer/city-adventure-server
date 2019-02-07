defmodule Domain.Creator.EventHandlers.User do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  def process(multi, %Domain.Event{aggregate_name: "Creator.User", name: "Created"} = event) do
    event.data
    |> case do
      %{
        id: id,
        password_digest: password_digest,
        email: email,
        name: name
      } ->
        creator =
          %Models.Creator{}
          |> Models.Creator.changeset(%{
            id: id,
            password_digest: password_digest,
            name: name,
            email: email
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, creator)

      _ ->
        multi
    end
  end
end
