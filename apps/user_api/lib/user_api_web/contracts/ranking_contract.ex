defmodule UserApiWeb.RankingContract do
  use UserApiWeb, :contract

  def index(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      adventure_id: :required
    })
  end

  def current_user_ranking(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      adventure_id: :required
    })
  end
end
