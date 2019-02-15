defmodule AdministrationApiWeb.QAContract do
  use AdministrationApiWeb, :contract

  defp list_filters(filter) do
    filter.filters
    |> cast(%{
      by_creator: Ecto.UUID,
      adventure_id: Ecto.UUID,
      is_creator: :boolean,
      is_administrator: :boolean,
      is_event: :boolean,
      administrator_id: Ecto.UUID,
      creator_id: Ecto.UUID
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
      administrator_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      content: :string
    })
    |> default(%{
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      administrator_id: :required,
      adventure_id: :required,
      content: :string
    })
  end
end
