defmodule Contract.Adventure.ClueListing do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :adventure_id, Ecto.UUID
  end

  @params ~w(adventure_id)a
  @required_params ~w(adventure_id)a

  def validate(params) do
    params
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