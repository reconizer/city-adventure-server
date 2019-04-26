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
end
