defmodule UserApiWeb.AdventureContract do
  use UserApiWeb, :contract

  def index(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      position: UserApi.Type.Position
    })
    |> validate(%{
      user_id: :required,
      position: :required
    })
  end

  def user_list(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      filter: Domain.Filter.Type
    })
    |> default(%{
      filter: Domain.Filter.new()
    })
    |> plug(%{
      filter: &list_filters/1
    })
    |> validate(%{
      user_id: :required,
      filter: :required
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

  def show(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      user_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      user_id: :required
    })
  end

  def start(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      user_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      user_id: :required
    })
  end

  def summary(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      user_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      user_id: :required
    })
  end

  def rating(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      user_id: Ecto.UUID,
      rating: :integer
    })
    |> validate(%{
      adventure_id: :required,
      user_id: :required,
      rating: :required
    })
  end

  defp list_filters(filter) do
    filter =
      filter
      |> default(%{
        offset: Domain.Filter.offset(filter)
      })

    filter.filters
    |> cast(%{
      completed: :boolean,
      paid: :boolean
    })
    |> default(%{
      completed: false
    })
    |> validate(%{
      completed: :required
    })
    |> case do
      {:ok, filters} -> {:ok, %{filter | filters: filters}}
      error -> error
    end
  end

  defp index_filters(filter) do
    filter =
      filter
      |> default(%{
        offset: Domain.Filter.offset(filter)
      })

    filter.filters
    |> cast(%{
      range: :float,
      name: :string,
      difficulty_level: :integer
    })
    |> validate(%{
      range: fn range ->
        range
        |> case do
          nil ->
            true

          result ->
            1 <= result and result <= 5
        end
      end,
      name: fn name ->
        name
        |> case do
          nil -> true
          result -> result |> String.length() >= 3
        end
      end,
      difficulty_level: fn level ->
        level
        |> case do
          nil -> true
          result -> result in [1, 2, 3]
        end
      end
    })
    |> case do
      {:ok, filters} -> {:ok, %{filter | filters: filters}}
      error -> error
    end
  end
end
