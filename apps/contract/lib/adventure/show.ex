defmodule Contract.Adventure.Show do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
  
  end

  @params ~w(id)a
  @required_params ~w(id)a

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