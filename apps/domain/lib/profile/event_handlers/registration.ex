defmodule Domain.Profile.EventHandlers.Registration do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  def process(multi, %Domain.Event{aggregate_name: "Profile.Registration", name: "Created"} = event) do
    user = Models.User.build(event.data)

    multi
    |> Ecto.Multi.insert({event.id, event.name}, user)
  end
end
