defmodule Infrastructure.Repository.Models do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias unquote(Application.get_env(:domain, :models)), as: Models
    end
  end

  def uuid() do
    Ecto.UUID.generate()
  end

  @spec load_type(any, any) :: any
  def load_type(value, type) do
    value
    |> type.load()
    |> case do
      {:ok, value} -> value
      _ -> nil
    end
  end

  @spec dump_type(any, any) :: any
  def dump_type(value, type) do
    value
    |> type.dump()
    |> case do
      {:ok, value} -> value
      _ -> nil
    end
  end

  @spec zip_results(map()) :: [map()]
  def zip_results(results) do
    results
    |> case do
      %{rows: rows, columns: columns} ->
        rows
        |> Enum.map(fn row ->
          Enum.zip(columns, row)
          |> Map.new()
        end)

      _ ->
        []
    end
  end

  @spec zip_result(map()) :: map() | nil
  def zip_result(results) do
    results
    |> zip_results()
    |> List.first()
  end
end
