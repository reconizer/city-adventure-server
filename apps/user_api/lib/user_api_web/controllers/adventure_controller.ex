defmodule UserApiWeb.AdventureController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.AdventureListing, as: AdventureListingProjection

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    position = %{
      lat: context |> Map.get("lat", nil),
      lng: context |> Map.get("lng", nil)
    }
    %Session{context: context} = session
    |> Session.update_context(%{"position" => position})
    with {:ok, validate_params} <- context
                                   |> Contract.Adventure.Listing.validate(),
      {:ok, start_points} <- validate_params 
                             |> AdventureListingProjection.get_start_points()
    do
      session
      |> Session.update_context(%{"start_points" => start_points})
      |> present(conn, UserApiWeb.AdventureView, "index.json")
    else
      {:error, reason} ->
        session
        |> Session.add_error(%{message: reason})
        |> present(conn, UserApiWeb.AdventureView, "index.json")
    end
  end

end
