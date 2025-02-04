defmodule Infrastructure.Repository.Models.Asset do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "assets" do
    field(:name, :string)
    field(:extension, :string)
    field(:type, :string)
    field(:uploaded, :boolean, default: false)

    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @fields ~w(id name extension uploaded type inserted_at updated_at)a
  @required_fields ~w(id name extension uploaded type inserted_at updated_at)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
