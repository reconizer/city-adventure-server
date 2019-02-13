defmodule Domain.Filter do
  defstruct filters: %{},
            orders: [],
            page: 1,
            limit: 20

  def new(params \\ %{}) do
    struct(Domain.Filter, params)
  end

  def set_page(filter, page) when page > 0 do
    %{filter | page: page}
  end

  def set_limit(filter, limit) do
    %{filter | limit: limit}
  end

  def offset(filter) do
    (filter.page - 1) * filter.limit
  end

  def add_filter(filter, name, value) do
    filter
    |> add_filter(%{name: name, value: value})
  end

  def add_filter(filter, %{name: name, value: value}) do
    %{filter | filters: filter.filters |> Map.put(name, value)}
  end

  def filters(filter) do
    filter.filters
  end

  def limit(filter) do
    filter.limit
  end
end

defmodule Domain.Filter.Type do
  @behaviour Ecto.Type

  def type, do: :map

  def cast(data) do
    {%{}, data}
    |> fetch_page
    |> fetch_filters
    |> fetch_order
    |> case do
      {{:ok, params}, _} ->
        filter = params |> Domain.Filter.new()

        {:ok, filter}

      {_, _} ->
        :error
    end
  end

  def load(data) do
    {:ok, data}
  end

  def dump(data) do
    {:ok, data}
  end

  defp fetch_field(data, field) do
    data
    |> Map.get(field, :undefined)
  end

  defp fetch_page({{:ok, params}, data}), do: fetch_page({params, data})
  defp fetch_page({{:error, _} = error, data}), do: {error, data}

  defp fetch_page({params, data}) do
    params =
      data
      |> fetch_field("page")
      |> case do
        :undefined ->
          {:ok, params}

        page ->
          page
          |> Integer.parse()
          |> case do
            :error ->
              {:error, :invalid_page}

            {page, _} ->
              {:ok, params |> Map.put(:page, page)}
          end
      end

    {params, data}
  end

  defp fetch_filters({{:ok, params}, data}), do: fetch_filters({params, data})
  defp fetch_filters({{:error, _} = error, data}), do: {error, data}

  defp fetch_filters({params, data}) do
    params =
      data
      |> fetch_field("filters")
      |> case do
        :undefined ->
          {:ok, params}

        filters when is_map(filters) ->
          {:ok, params |> Map.put(:filters, filters)}

        _ ->
          {:ok, params}
      end

    {params, data}
  end

  defp fetch_order({{:ok, params}, data}), do: fetch_order({params, data})
  defp fetch_order({{:error, _} = error, data}), do: {error, data}
  defp fetch_order({params, data}), do: {{:ok, params}, data}
end
