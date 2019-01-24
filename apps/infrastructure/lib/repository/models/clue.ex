defmodule Infrastructure.Repository.Models.Clue do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Point,
    Asset
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "clues" do
    field(:type, :string)
    field(:tip, :boolean)
    field(:description, :string)
    field(:sort, :integer)

    timestamps()

    belongs_to(:asset, Asset)
    belongs_to(:point, Point)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(point_id type sort tip description asset_id)a
  @required_params ~w(point_id type sort)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:point_id)
  end
end
