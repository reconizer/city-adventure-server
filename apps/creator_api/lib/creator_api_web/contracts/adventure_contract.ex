defmodule CreatorApiWeb.AdventureContract do
  use CreatorApiWeb, :contract

  def list(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required
    })
  end

  def item(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def statistics(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      name: :string,
      position: CreatorApi.Type.Position
    })
    |> default(%{
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      name: :required,
      position: :required
    })
  end

  def update(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      description: :string,
      language: :string,
      difficulty_level: :integer,
      min_time: :integer,
      max_time: :integer,
      name: :string,
      show: :boolean
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def send_to_pending(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def send_to_review(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def upload_image(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      extension: :string
    })
    |> default(%{
      id: Ecto.UUID.generate(),
      type: "image"
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required,
      id: :required,
      type: :required,
      extension: :required
    })
  end
end
