defmodule Domain.Creator.User.Adventure do
  use Ecto.Schema
  use Domain.Event, "Creator.User"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
  end

  @fields ~w(id name)a
  @required_fields @fields

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
