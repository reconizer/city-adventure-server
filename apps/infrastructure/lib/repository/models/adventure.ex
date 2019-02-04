defmodule Infrastructure.Repository.Models.Adventure do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Point,
    Asset,
    Image,
    UserAdventure,
    AdventureRating,
    Creator,
    CreatorAdventureRating
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "adventures" do
    field(:description, :string)
    field(:code, :string)
    field(:language, :string)
    field(:difficulty_level, :integer)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:name, :string)
    field(:published, :boolean)
    field(:status, :string)
    field(:show, :boolean)

    timestamps()

    belongs_to(:asset, Asset)
    belongs_to(:creator, Creator)
    has_one(:creator_adventure_rating, CreatorAdventureRating)
    has_many(:points, Point)
    has_many(:images, Image)
    has_many(:user_adventures, UserAdventure)
    has_many(:adventure_ratings, AdventureRating)
    has_many(:user_points, through: [:points, :user_points])
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(id description code language difficulty_level min_time max_time published show name creator_id asset_id status)a
  @required_params ~w(name creator_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_number(:difficulty_level, greater_than_or_equal_to: 1)
    |> validate_number(:difficulty_level, less_than_or_equal_to: 3)
    |> foreign_key_constraint(:creator_id)
  end
end
