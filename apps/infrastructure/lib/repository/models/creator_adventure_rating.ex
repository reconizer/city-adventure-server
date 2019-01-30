defmodule Infrastructure.Repository.Models.CreatorAdventureRating do
  @type t :: %__MODULE__{}
  @moduledoc """
  **Database View**
  Representation of adventure_rating_view
  """

  use Ecto.Schema
  alias Infrastructure.Repository.Models
  @primary_key false
  @foreign_key_type :binary_id

  schema "adventure_rating_view" do
    belongs_to :adventure, Models.Adventure, foreign_key: :adventure_id
    field(:rating, :decimal)
  end
end
