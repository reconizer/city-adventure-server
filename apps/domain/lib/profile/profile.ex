defmodule Domain.Profile.Profile do
  @moduledoc """
  Domain for profile management
  """

  use Ecto.Schema
  use Domain.Event, "Profile"
  import Ecto.Changeset

  alias Domain.Profile.Avatar

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:nick, :string)
    field(:email, :string)
    embeds_one(:avatar, Avatar)

    aggregate_fields()
  end
end
