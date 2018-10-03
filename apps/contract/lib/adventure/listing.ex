defmodule Contract.Adventure.Listing do
  use Ecto.Schema
  import Ecto.Changeset
  alias Contract.Position
  alias Contract.User.Profile

  @primary_key false

  embedded_schema do
    field :position, Geo.Point
    embeds_one :current_user, Profile
  end

  @params ~w(position)a
  @required_params ~w(position current_user)a

  def validate(params) do
    params
    |> Position.position_cast()
    |> changeset()
    |> case do
      %{valid?: true} = result -> 
        {:ok, result
              |> apply_changes()
        }
      result -> {:error, result} 
    end
  end

  defp changeset(params) do 
    %__MODULE__{}
    |> cast(params, @params)
    |> cast_embed(:current_user)
    |> validate_required(@required_params)
  end

end