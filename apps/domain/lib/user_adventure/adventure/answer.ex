defmodule Domain.UserAdventure.Adventure.Answer do
  alias Domain.UserAdventure.Adventure.Answer
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:type, :string)
    field(:details, :map)
    field(:point_id, Ecto.UUID)
  end

  @fields [:details, :type, :point_id, :id]
  @required_fields @fields

  @spec changeset(Answer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
