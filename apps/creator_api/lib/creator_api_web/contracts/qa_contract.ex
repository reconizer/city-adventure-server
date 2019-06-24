defmodule CreatorApiWeb.QAContract do
  use CreatorApiWeb, :contract

  defp list_filters(filter) do
    filter.filters
    |> cast(%{
      adventure_id: Ecto.UUID,
      timestamp: :integer
    })
    |> default(%{
      timestamp: NaiveDateTime.utc_now() |> Timex.to_unix()
    })
    |> validate(%{
      adventure_id: :required,
      timestamp: :required
    })
    |> case do
      {:ok, filters} -> {:ok, %{filter | filters: filters}}
      error -> error
    end
  end

  def list(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      author: CreatorApi.Type.Author,
      filter: Domain.Filter.Type
    })
    |> default(%{
      filter: Domain.Filter.new()
    })
    |> plug(%{
      filter: &list_filters/1
    })
    |> validate(%{
      creator_id: :required
    })
  end

  def create(conn, params) do
    params =
      params
      |> with_creator(conn)

    params
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      author: AdministrationApi.Type.Author,
      content: :string
    })
    |> default(%{
      id: Ecto.UUID.generate(),
      author: CreatorApi.Type.Author.new(params)
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required,
      content: :string
    })
  end
end
