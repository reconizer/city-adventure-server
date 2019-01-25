defmodule Domain.Event do
  defmacro __using__(aggregate) do
    quote do
      import Domain.Event, only: [aggregate_fields: 0]

      def emit!({:ok, aggregate_struct}, event_name, event_data), do: emit!(aggregate_struct, event_name, event_data)
      def emit!({:error, _} = error, _, _), do: error

      def emit!(aggregate_struct, event_name, event_data) do
        emit(aggregate_struct, event_name, event_data)
        |> case do
          {:ok, aggregate} -> aggregate
        end
      end

      def emit({:ok, aggregate_struct}, event_name, event_data), do: emit(aggregate_struct, event_name, event_data)
      def emit({:error, _} = error, _, _), do: error

      def emit(aggregate_struct, event_name, event_data) do
        event_data =
          event_data
          |> case do
            %{__struct__: _} = struct -> struct |> Map.from_struct()
            map -> map
          end
          |> Enum.map(fn
            {key, %Ecto.Changeset{} = value} -> {key, value |> Ecto.Changeset.apply_changes()}
            other -> other
          end)
          |> Enum.into(%{})

        event = %Domain.Event{
          id: Ecto.UUID.generate(),
          aggregate_id: aggregate_struct.id,
          aggregate_name: unquote(aggregate),
          name: event_name,
          data: event_data,
          created_at: NaiveDateTime.utc_now()
        }

        event
        |> Domain.EventHandler.emit()
        |> case do
          {:ok, multi} ->
            aggregate_struct
            |> case do
              %{operations: nil} ->
                {:ok, %{aggregate_struct | operations: multi, events: aggregate_struct.events ++ [event]}}

              %{operations: current_operations} ->
                {:ok, %{aggregate_struct | operations: current_operations |> Ecto.Multi.append(multi), events: aggregate_struct.events ++ [event]}}
            end

          {:error, _} = error ->
            error
        end
      end
    end
  end

  defmacro aggregate_fields() do
    quote do
      Ecto.Schema.embeds_many(:events, Domain.Event)
      Ecto.Schema.field(:operations, {:array, Ecto.Multi}, default: Ecto.Multi.new())
    end
  end

  alias Domain.Event
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field(:aggregate_id, :binary_id)
    field(:aggregate_name, :string)
    field(:name, :string)
    field(:data, :map)
    field(:created_at, :naive_datetime)
  end

  @fields [:id, :aggregate_id, :aggregate_name, :name, :data, :created_at]
  @required_fields @fields

  @spec changeset(Event.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
