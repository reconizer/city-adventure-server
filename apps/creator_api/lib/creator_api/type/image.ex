defmodule CreatorApi.Type.Image do
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:url, :string)
  end

  @fields ~w(id url)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
