defmodule Domain.Administration.EventHandler.User do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  def process(multi, %Domain.Event{aggregate_name: "Administration.User", name: "Created"} = event) do
    event.data
    |> case do
      %{
        id: id,
        password_digest: password_digest,
        email: email,
        name: name
      } ->
        creator =
          %Models.Administrator{}
          |> Models.Administrator.changeset(%{
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
