defmodule Contract do

  defmacro __using__(_) do
    quote do
      import Ecto.Changeset
      @before_compile Contract     
    end
  end
 
  defmacro __before_compile__(_) do
    quote do
      def validate(params) do
        %__MODULE__{}
        |> changeset(params)
        |> case do
          %{valid?: true} = result -> 
            {:ok, result
                  |> apply_changes()
            }
          result -> {:error, result.errors} 
        end
      end     
    end
  end

end
