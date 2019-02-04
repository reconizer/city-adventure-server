defmodule Domain.Creator.Adventure.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key false
  embedded_schema do
    field(:lat, :float)
    field(:lng, :float)
  end

  @fields ~w(lat lng)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
