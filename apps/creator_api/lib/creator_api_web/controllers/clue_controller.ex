defmodule CreatorApiWeb.ClueController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.ClueContract
  alias Domain.Creator

  def item(conn, params) do
    ClueContract.item(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> case do
          {:ok, adventure} ->
            adventure
            |> Creator.Adventure.get_clue(params.id)
            |> case do
              {:ok, clue} ->
                conn
                |> render("item.json", %{item: clue})

              {:error, errors} ->
                conn
                |> handle_errors(errors)
            end

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    ClueContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
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

              {:error, errors} ->
                conn
                |> handle_errors(errors)
            end

          error ->
            error
            |> handle_repository_action(conn)
        end

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

  def upload_file_path(conn, params) do
    ClueContract.upload_file_path(conn, params)
    |> case do
      {:ok, params} ->
        adventure =
          Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
          |> Domain.Creator.Adventure.add_asset_to_clue(params)
          |> Domain.Creator.Repository.Adventure.save()

        Domain.Creator.Adventure.get_clue(adventure, params.clue_id)
        |> case do
          {:ok, clue} ->
            conn
            |> render("upload_asset.json", %{clue: clue})

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
