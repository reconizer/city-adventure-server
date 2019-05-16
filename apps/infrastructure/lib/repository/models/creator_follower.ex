defmodule Infrastructure.Repository.Models.CreatorFollowe do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  alias Infrastructure.Repository.Models
  @primary_key false
  @foreign_key_type :binary_id

  schema "creator_followers" do
    belongs_to(:user, Models.User, foreign_key: :user_id)
    belongs_to(:creator, Models.Creator, foreign_key: :creator_id)
  end
end
