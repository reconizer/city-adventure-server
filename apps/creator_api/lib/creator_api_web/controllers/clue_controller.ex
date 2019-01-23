defmodule CreatorApiWeb.ClueController do
  use CreatorApiWeb, :controller

  alias Domain.Creator
  import Contract

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      creator_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean
    })
    |> default(%{
      tip: false
    })
    |> validate(%{
      adventure_id: :required,
      creator_id: :required,
      point_id: :required,
      type: :required,
      description: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      id: :required,
      adventure_id: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      clue_order: {:array, CreatorApi.Type.ClueOrder}
    })
    |> validate(%{
      creator_id: :required,
      clue_order: :required,
      adventure_id: :required
    })
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
