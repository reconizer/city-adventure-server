defmodule Domain.Creator.User.Adventure do
  use Ecto.Schema
  use Domain.Event, "Creator.User"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
  end

  @fields ~w(id)a
  @required_fields @fields

  @spec changeset(Transfer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
