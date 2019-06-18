defmodule Domain.AdventureReview.EventHandler.Message do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  @aggregate_name "AdventureReview.Message"

  def process(multi, %Domain.Event{aggregate_name: @aggregate_name, name: "Created"} = event) do
    params = %{
      id: event.aggregate_id,
      content: event.data.content,
      inserted_at: event.data.created_at,
      adventure_id: event.data.adventure_id
    }

    model =
      event.data.author_type
      |> case do
        "administrator" ->
          %Models.AdministratorAdventureMessage{}
          |> Models.AdministratorAdventureMessage.changeset(
            params
            |> Map.put(:administrator_id, event.data.author_id)
          )

        "creator" ->
          %Models.CreatorAdventureMessage{}
          |> Models.CreatorAdventureMessage.changeset(
            params
            |> Map.put(:creator_id, event.data.author_id)
          )
      end

    multi
    |> Ecto.Multi.insert({event.id, event.name}, model)
  end
end
