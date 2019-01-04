defmodule Domain.Repository do
  defmacro __using__(_env) do
    quote do
      def save(aggregate) do
        aggregate.operations
        |> Infrastructure.Repository.transaction()
      end
    end
  end
end
