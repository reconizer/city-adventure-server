defmodule UserApiWeb.AdventureController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.AdventureListing, as: AdventureListingProjection

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    context
    |> Contract.Adventure.Listing.validate([:position], [:position])
    |> AdventureListingProjection.get_start_points()
    render conn, "index.json", context
  end
end
