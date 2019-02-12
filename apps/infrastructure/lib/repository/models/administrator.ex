defmodule Infrastructure.Repository.Models.Administrator do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "administrators" do
    field(:name, :string)
    field(:email, :string)
    field(:password_digest, :string)

    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(id name email password_digest )a
  @required_params ~w(name email password_digest)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> unique_constraint(:email)
  end
end
