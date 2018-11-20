defmodule Infrastructure.Repository.Models.AdventureRating do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Adventure,
    User
  }

  @primary_key false
  @foreign_key_type :binary_id

  schema "adventure_ratings" do
    field :rating, :integer

    timestamps()

    belongs_to :adventure, Adventure, primary_key: true
    belongs_to :user, User, primary_key: true

  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(user_id adventure_id rating)a
  @required_params ~w(adventure_id user_id rating)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:adventure_id)
    |> foreign_key_constraint(:user_id)
  end

end
