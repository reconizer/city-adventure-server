defmodule CreatorApiWeb.PointContract do
  use CreatorApiWeb, :contract

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: CreatorApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean
    })
    |> default(%{
      show: false,
      radius: 10,
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required,
      position: :required,
      parent_point_id: :required
    })
  end

  def update(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: CreatorApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean,
      time_answer: CreatorApi.Type.TimeAnswer,
      password_answer: CreatorApi.Type.PasswordAnswer
    })
    |> validate(%{
      creator_id: :required,
      id: :required,
      adventure_id: :required
    })
  end

  def delete(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      creator_id: :required,
      id: :required
    })
  end

  def reorder(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      point_order: {:array, CreatorApi.Type.PointOrder},
      adventure_id: Ecto.UUID,
      creator_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      creator_id: :required,
      point_order: :required
    })
  end
end
