defmodule Infrastructure.Repository.Models.UserRanking do
  @type t :: %__MODULE__{}
  @moduledoc """
  **Database View**
  Representation of user_ranking_view
  """

  use Ecto.Schema
  alias Infrastructure.Repository.Models
  @primary_key false
  @foreign_key_type :binary_id

  schema "user_ranking_view" do
    belongs_to :user, Models.User, foreign_key: :user_id
    belongs_to :adventure, Models.Adventure, foreign_key: :adventure_id
    field :position, :integer
    field :nick, :string
    field :completion_time, :time
  end
end
