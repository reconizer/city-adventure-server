defmodule Domain.UserAdventure.Adventure.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Domain.UserAdventure.Adventure.Asset

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:sort, :integer)
    field(:adventure_id, :binary_id)
    embeds_one(:asset, Asset)
  end

  @fields ~w(sort adventure_id)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
