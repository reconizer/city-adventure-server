defmodule Infrastructure.Repository.Models.Adventure do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Point,
    Asset,
    Image,
    UserAdventure,
    Creator
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "adventures" do
    field :description, :string
    field :code, :string
    field :language, :string
    field :difficulty_level, :integer
    field :min_time, :time
    field :max_time, :time
    field :name, :string
    field :published, :boolean
    field :show, :boolean

    timestamps()

    belongs_to :asset, Asset
    belongs_to :creator, Creator
    has_many :points, Point
    has_many :images, Image
    has_many :user_adventures, UserAdventure
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(description code language difficulty_level min_time max_time published show name creator_id asset_id)a
  @required_params ~w(language description creator_id asset_id language difficulty_level name)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    # |> validate_number(:max_time, greater_than: :min_time)
    # |> validate_number(:min_time, less_than: :max_time)
    |> validate_number(:difficulty_level, greater_than_or_equal_to: 1)
    |> validate_number(:difficulty_level, less_than_or_equal_to: 3)
  end

end
