defmodule Infrastructure.Repository.Models.AdventureLog do
  @type t :: %__MODULE__{}
  @moduledoc """
  **Database View**
  Representation of adventure messages and status changes
  """

  use Ecto.Schema
  alias Infrastructure.Repository.Models.Adventure

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "adventure_logs" do
    field(:content, :string)
    field(:author_id, :binary_id)
    field(:type, :string)
    field(:created_at, :naive_datetime)

    belongs_to(:adventure, Adventure)
  end
end
