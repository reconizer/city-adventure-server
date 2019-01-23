defmodule CreatorApi.Type.Clue do
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:point_id, :binary_id)
    field(:tip, :boolean)
    field(:type, :string)
    field(:url, :string)
    field(:description, :string)
  end

  @fields ~w(id point_id tip type url description)a
  @required_fields @fields -- [:tip]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
