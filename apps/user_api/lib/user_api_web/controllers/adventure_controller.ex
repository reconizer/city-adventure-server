defmodule UserApiWeb.AdventureController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Listing, as: ListingProjection
  alias Domain.Adventure.Projections.Adventure, as: AdventureProjection

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
                             |> ListingProjection.get_start_points(context["current_user"])
    do
      session
      |> Session.update_context(%{"adventures" => start_points})
      |> present(conn, UserApiWeb.AdventureView, "index.json")
    else
      {:error, reason} ->
        session
        |> Session.add_error(reason)
        |> present(conn, UserApiWeb.AdventureView, "index.json")
    end
  end

  def show(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with {:ok, validate_params} <- context 
                                   |> Contract.Adventure.Show.validate(),
         {:ok, adventure} <- AdventureProjection.get_adventure_by_id(validate_params)
    do
      session
      |> Session.update_context(%{"adventure" => adventure})
      |> present(conn, UserApiWeb.AdventureView, "show.json")
    else
      {:error, reason} ->
        session
        |> Session.add_error(reason)
        |> present(conn, UserApiWeb.AdventureView, "show.json")
    end

  end

end
