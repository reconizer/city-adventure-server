defmodule CreatorApiWeb.AdventureController do
  use CreatorApiWeb, :controller

  import Contract

  alias Domain.Creator

  def list(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required
    })
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventures(params.creator_id)
        |> case do
          {:ok, adventures} ->
            conn
            |> render("list.json", %{list: adventures})

          {:error, error} ->
            conn
            |> handle_errors(error)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def item(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> case do
          {:ok, adventure} ->
            conn
            |> render("item.json", %{item: adventure})

          {:error, error} ->
            conn
            |> handle_errors(error)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def statistics(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
    |> case do
      {:ok, params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      name: :string,
      position: CreatorApi.Type.Position
    })
    |> validate(%{
      creator_id: :required,
      name: :required,
      position: :required
    })
    |> case do
      {:ok, params} ->
        Domain.Creator.Adventure.new(params)
        |> Domain.Creator.Repository.Adventure.save()
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
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      description: :string,
      language: :string,
      difficulty_level: :integer,
      min_time: :time,
      max_time: :time,
      name: :string,
      show: :boolean
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.change(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
