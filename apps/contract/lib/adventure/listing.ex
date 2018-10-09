defmodule Contract.Adventure.Listing do
  use Ecto.Schema
  import Ecto.Changeset
  alias Contract.Position

  @primary_key false

  embedded_schema do
    field :position, Geo.Point
  end

  @params ~w(position)a
  @required_params ~w(position)a

  def validate(params) do
    params
    |> Position.position_cast()
    |> changeset()
    |> case do
      %{valid?: true} = result -> 
        {:ok, result
              |> apply_changes()
        }
      result -> {:error, result.errors} 
    end
  end

  defp changeset(params) do 
    %__MODULE__{}
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end