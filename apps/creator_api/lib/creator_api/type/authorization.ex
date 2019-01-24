defmodule CreatorApi.Type.Authorization do
  use CreatorApi.Type

  embedded_schema do
    field(:token, :string)
  end

  @fields ~w(token)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
