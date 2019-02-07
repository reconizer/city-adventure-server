defmodule Infrastructure.Repository.Models.Point do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Adventure,
    Point,
    Answer,
    Clue,
    UserPoint
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "points" do
    field(:show, :boolean)
    field(:radius, :integer)
    field(:position, Geo.PostGIS.Geometry)

    timestamps()

    belongs_to(:adventure, Adventure)
    belongs_to(:parent_point, Point)

    has_many(:answers, Answer)
    has_many(:clues, Clue)
    has_many(:user_points, UserPoint)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(id parent_point_id adventure_id show position radius)a
  @required_params ~w(adventure_id position radius)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:adventure_id)
  end
end
