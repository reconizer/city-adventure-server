defmodule UserApiWeb.CreatorContract do
  use UserApiWeb, :contract

  def show(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      user_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      user_id: :required
    })
  end

  def index_filter(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      position: UserApi.Type.Position,
      filter: Domain.Filter.Type
    })
    |> default(%{
      filter: Domain.Filter.new()
    })
    |> plug(%{
      filter: &index_filters/1
    })
    |> validate(%{
      user_id: :required,
      position: :required,
      filter: :required
    })
  end

  def adventure_list(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      filter: Domain.Filter.Type
    })
    |> default(%{
      filter: Domain.Filter.new()
    })
    |> plug(%{
      filter: &list_filters/1
    })
    |> validate(%{
      filter: :required,
      creator_id: :required
    })
  end

  defp list_filters(filter) do
    result =
      filter
      |> default(%{
        offset: Domain.Filter.offset(filter)
      })

    {:ok, result}
  end

  defp index_filters(filter) do
    filter =
      filter
      |> default(%{
        offset: Domain.Filter.offset(filter)
      })

    filter.filters
    |> cast(%{
      range: :boolean,
      name: :string
    })
    |> validate(%{
      name: fn name ->
        name
        |> case do
          nil -> true
          result -> result |> String.length() >= 3
        end
      end
    })
    |> case do
      {:ok, filters} -> {:ok, %{filter | filters: filters}}
      error -> error
    end
  end
end
