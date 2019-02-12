defmodule AdministrationApiWeb.PointController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.PointContract
  alias Domain.Creator.Repository.Adventure, as: AdventureRepository
  alias Domain.Creator

  @doc """
  path: /api/points/:id
  method: GET
  """
  def item(conn, params) do
    with {:ok, params} <- PointContract.item(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id),
         {:ok, point} <- Creator.Adventure.get_point(adventure, params.id) do
      conn
      |> render("item.json", %{item: point})
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/points
  method: GET
  """
  def list(conn, params) do
    with {:ok, params} <- PointContract.list(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      conn
      |> render("list.json", %{list: adventure.points})
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/points
  method: CREATE
  """
  def create(conn, params) do
    with {:ok, params} <- PointContract.create(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Creator.Adventure.add_point(%{
        id: params.id,
        parent_point_id: params.parent_point_id,
        radius: params.radius,
        show: params.show,
        position: %{
          lat: params.position.lat,
          lng: params.position.lng
        }
      })
      |> Domain.Creator.Repository.Adventure.save()
      |> case do
        {:ok, adventure} ->
          adventure
          |> Creator.Adventure.get_point(params.id)
          |> case do
            {:ok, point} ->
              conn
              |> render("item.json", %{item: point})

            error ->
              handle_error(conn, error)
          end

        error ->
          handle_repository_action(conn, error)
      end
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/points
  method: PATCH
  """
  def update(conn, params) do
    with {:ok, params} <- PointContract.update(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.change_point(params)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/points
  method: DELETE
  """
  def delete(conn, params) do
    with {:ok, params} <- PointContract.delete(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.remove_point(params.id)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/points/reorder
  method: PATCH
  """
  def reorder(conn, params) do
    with {:ok, params} <- PointContract.reorder(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.reorder_points(params.point_order)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error -> handle_error(conn, error)
    end
  end
end
