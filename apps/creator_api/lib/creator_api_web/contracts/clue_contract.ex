defmodule CreatorApiWeb.ClueContract do
  use CreatorApiWeb, :contract

  def item(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      id: Ecto.UUID
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      creator_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean,
      url: :string
    })
    |> default(%{
      tip: false,
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      adventure_id: :required,
      creator_id: :required,
      point_id: :required,
      type: :required,
      description: :required
    })
  end

  def update(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean,
      url: :string
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required
    })
  end

  def delete(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      id: :required,
      adventure_id: :required
    })
  end

  def reorder(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      clue_order: {:array, CreatorApi.Type.ClueOrder}
    })
    |> validate(%{
      creator_id: :required,
      clue_order: :required,
      adventure_id: :required
    })
  end

  def upload_file_path(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      clue_id: Ecto.UUID,
      type: :string,
      extension: :string
    })
    |> default(%{
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required,
      clue_id: :required,
      id: :required,
      type: [
        :required,
        fn type ->
          type in ["clue_audio", "clue_image", "clue_video"]
        end
      ],
      extension: :required
    })
  end
end
