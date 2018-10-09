defmodule Infrastructure.Repository.Models.Adventure do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Point,
    Image
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "adventures" do
    field :description, :string
    field :code, :string
    field :language, :string
    field :difficulty_level, :integer
    field :estimated_time, :time
    field :name, :string
    field :published, :boolean
    field :show, :boolean

    timestamps()

    has_many :points, Point
    has_many :images, Image
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(description code language difficulty_level estimated_time published show name)a
  @required_params ~w(language description)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
