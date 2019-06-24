defmodule AdministrationApiWeb.AdventureContract do
  use AdministrationApiWeb, :contract

  defp list_filters(filter) do
    filter.filters
    |> cast(%{
      by_creator: Ecto.UUID
    })
    |> case do
      {:ok, filters} -> {:ok, %{filter | filters: filters}}
      error -> error
    end
  end

  def list(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      filter: Domain.Filter.Type
    })
    |> default(%{
      filter: Domain.Filter.new()
    })
    |> plug(%{
      filter: &list_filters/1
    })
    |> validate(%{
      administrator_id: :required,
      filter: :required
    })
  end

  def item(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      administrator_id: :required
    })
  end

  def statistics(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      name: :string,
      position: AdministrationApi.Type.Position,
      creator_id: Ecto.UUID
    })
    |> default(%{
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      name: :required,
      position: :required,
      administrator_id: :required,
      creator_id: :required
    })
  end

  def update(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      description: :string,
      language: :string,
      difficulty_level: :integer,
      min_time: :integer,
      max_time: :integer,
      status: :string,
      name: :string,
      show: :boolean
    })
    |> validate(%{
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def send_to_pending(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def send_to_review(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required,
      adventure_id: :required
    })
  end
end
