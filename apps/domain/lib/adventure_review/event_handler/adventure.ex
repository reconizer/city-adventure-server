defmodule Domain.AdventureReview.EventHandler.Adventure do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  @aggregate_name "AdventureReview.Adventure"

  alias Infrastructure.Repository

  def process(multi, %Domain.Event{aggregate_name: @aggregate_name, name: "Changed"} = event) do
    updates =
      event.data
      |> Map.take([
        :status
      ])

    adventure =
      Models.Adventure
      |> Repository.get(event.aggregate_id)
      |> Models.Adventure.changeset(updates)

    multi
    |> Ecto.Multi.update({event.id, event.name}, adventure)
  end
end
