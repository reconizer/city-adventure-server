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

  def follow_unfollow(conn, params) do
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
end
