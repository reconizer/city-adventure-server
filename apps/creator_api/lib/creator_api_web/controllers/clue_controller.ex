defmodule CreatorApiWeb.ClueController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.ClueContract
  alias Domain.Creator

  def create(conn, params) do
    ClueContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Creator.Adventure.add_clue(%{
          point_id: params.point_id,
          type: params.type,
          description: params.description,
          tip: params.tip
        })
        |> Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def update(conn, params) do
    ClueContract.update(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.change_clue(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def delete(conn, params) do
    ClueContract.delete(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.remove_clue(params.id)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def reorder(conn, params) do
    ClueContract.reorder(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.reorder_clues(params.clue_order)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
