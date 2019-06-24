defmodule CreatorApiWeb.QAContract do
  use CreatorApiWeb, :contract

  def list(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      author: CreatorApi.Type.Author
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
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
