defmodule Contract.Adventure.Listing do
  use Ecto.Schema
  import Ecto.Changeset
  alias Contract.Position

  @primary_key false

  embedded_schema do
    field :position, Geo.Point
  end

  def validate(params, cast_list, validate_list) do
    params
    |> Position.position_cast()
    |> changeset(cast_list, validate_list)
  end

  defp changeset(params, cast_list, validate_list) do 
    %__MODULE__{}
    |> cast(params, cast_list)
    |> validate_required(validate_list)
    |> apply_changes()
  end

end