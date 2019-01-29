defmodule Domain.Creator.User.Adventure do
  use Ecto.Schema
  use Domain.Event, "Creator.User"
  import Ecto.Changeset

  alias Domain.Creator.User

  @type t :: %__MODULE__{}
  @type ok_t :: t | {:ok, %__MODULE__{}}
  @type error :: {:error, any()}
  @type aggregate :: ok_t() | error

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:rating, :decimal)
    field(:show, :boolean)
    field(:status, :string)
    embeds_one(:asset, User.Asset)
    embeds_many(:images, User.Image)
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
