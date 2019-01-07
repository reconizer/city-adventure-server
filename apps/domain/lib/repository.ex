defmodule Domain.Repository do
  defmacro __using__(_env) do
    quote do
      def save!(aggregate) do
        aggregate
        |> save()
        |> case do
          {:ok, aggregate} -> aggregate
        end
      end

      def save(aggregate) do
        alias Infrastructure.Repository
        alias Infrastructure.Repository.Models.Event

        aggregate.events
        |> Enum.reduce(aggregate.operations, fn event, multi ->
          persisted_event =
            %Event{}
            |> Event.changeset(%{
              id: event.id,
              aggregate_id: event.aggregate_id,
              aggregate_name: event.aggregate_name,
              name: event.name,
              data: event.data,
              created_at: event.created_at
            })

          multi
          |> Ecto.Multi.insert({"event", event.id}, persisted_event)
        end)
        |> Repository.transaction()
        |> case do
          {:ok, _} ->
            {:ok, %{aggregate | events: [], operations: Ecto.Multi.new()}}

          other ->
            other
        end
      end
    end
  end
end
