defmodule CreatorApi.Type.Adventure do
  use CreatorApi.Type
  alias CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:name, :string)
    field(:cover_url, :string)
    field(:published, :boolean)
    field(:hidden, :boolean)
    field(:rating, :float)
    field(:difficulty, :float)
    field(:min_duration, :integer)
    field(:max_duration, :integer)
    field(:description, :string)

    embeds_many(:images, Type.Image)
  end

  @fields ~w(id name cover_url published hidden rating difficulty min_duration max_duration description)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:images)
  end
end
