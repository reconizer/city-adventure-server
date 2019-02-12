defmodule AdministrationApiWeb.ClueController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.ClueContract
  alias Domain.Creator.Repository.Adventure, as: AdventureRepository
  alias Domain.Creator

  @doc """
  path: /api/clues/:id
  method: GET
  """
  def item(conn, params) do
    with {:ok, params} <- ClueContract.item(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id),
         {:ok, clue} <- Creator.Adventure.get_clue(adventure, params.id) do
      conn
      |> render("item.json", %{item: clue})
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/clues
  method: POST
  """
  def create(conn, params) do
    with {:ok, params} <- ClueContract.create(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Creator.Adventure.add_clue(%{
        id: params.id,
        point_id: params.point_id,
        type: params.type,
        description: params.description,
        tip: params.tip,
        url: Map.get(params, :url)
      })
      |> Creator.Repository.Adventure.save()
      |> case do
        {:ok, adventure} ->
          adventure
          |> Creator.Adventure.get_clue(params.id)
          |> case do
            {:ok, clue} ->
              conn
              |> render("item.json", %{item: clue})

            error ->
              conn
              |> handle_error(error)
          end

        error ->
          handle_repository_action(conn, error)
      end
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  @doc """
  path: /api/clues
  method: PATCH
  """
  def update(conn, params) do
    with {:ok, params} <- ClueContract.update(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.change_clue(params)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error -> handle_error(conn, error)
    end
  end

  @doc """
  path: /api/clues
  method: DELETE
  """
  def delete(conn, params) do
    with {:ok, params} <- ClueContract.delete(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.remove_clue(params.id)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error ->
        handle_error(conn, error)
    end
  end

  @doc """
  path: /api/clues/reorder
  method: PATCH
  """
  def reorder(conn, params) do
    with {:ok, params} <- ClueContract.reorder(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      adventure
      |> Domain.Creator.Adventure.reorder_clues(params.clue_order)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error ->
        handle_error(conn, error)
    end
  end
end
