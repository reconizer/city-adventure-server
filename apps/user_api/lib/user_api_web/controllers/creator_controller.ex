defmodule UserApiWeb.CreatorController do
  use UserApiWeb, :controller
  alias Domain.CreatorProfile.Repository.Creator, as: CreatorRepository
  alias Domain.CreatorProfile.Repository.Adventure, as: AdventureRepository
  alias Domain.Profile.CreatorProfile, as: CreatorProfileDomain
  alias UserApiWeb.CreatorContract

  def show(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> CreatorContract.show(context),
         {:ok, creator} <- validate_params |> CreatorRepository.get() do
      session
      |> Session.update_context(%{"creator" => creator})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.CreatorView, "show.json")
  end

  def creator_list(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    position = %{
      "lat" => context |> Map.get("lat", nil),
      "lng" => context |> Map.get("lng", nil)
    }

    filters = %{
      "filters" => context |> Map.get("filters", %{}),
      "orders" => context |> Map.get("orders", []),
      "page" => context |> Map.get("page", "1")
    }

    with %Session{valid?: true, context: context} <-
           session
           |> Session.update_context(%{"position" => position, "filter" => filters}),
         {:ok, validate_params} <-
           conn
           |> CreatorContract.index_filter(context),
         {:ok, adventures} <-
           validate_params
           |> CreatorRepository.all() do
      session
      |> Session.update_context(%{"adventures" => adventures})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "index_filter.json")
  end

  def adventure_list(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, %{creator_id: creator_id, filter: filter}} <-
           conn
           |> CreatorContract.adventure_list(context),
         {:ok, adventures} <- creator_id |> AdventureRepository.get_by_creator_id(filter) do
      session
      |> Session.update_context(%{"adventure_list" => adventures})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.CreatorView, "adventure_list.json")
  end
end
