defmodule Infrastructure.Repository.Models.Event do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "events" do
    field(:aggregate_id, :binary_id)
    field(:aggregate_name, :string)
    field(:name, :string)
    field(:data, :map)
    field(:created_at, :naive_datetime)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @fields ~w(id aggregate_id aggregate_name name data created_at)a
  @required_fields @fields

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
