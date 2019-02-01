defmodule UserApiWeb.RankingContract do
  use UserApiWeb, :contract

  def index(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      id: :required
    })
  end

  def current_user_ranking(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      id: :required
    })
  end

end