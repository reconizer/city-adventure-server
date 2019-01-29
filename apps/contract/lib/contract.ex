defmodule Contract do
  @type validate_params_t :: %{required(atom()) => any()}
  @type error :: {:error, any()}
  @type validate_params :: validate_params | {:ok, validate_params} | error
  @type validate_result :: {:ok, Ecto.Changeset.t()} | error

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
            {:ok, result |> apply_changes()}

          result ->
            {:error, result.errors}
        end
      end
    end
  end

  def default({:ok, params}, defaults) do
    default(params, defaults)
  end

  def default({:error, _} = error, _) do
    error
  end

  def default(params, defaults) do
    defaults
    |> Enum.reduce(params, fn {key, value}, params ->
      params
      |> Map.get(key)
      |> case do
        nil -> params |> Map.put(key, value)
        _ -> params
      end
    end)
  end

  def cast({:ok, params}, types) do
    cast(params, types)
  end

  def cast({:error, _} = error, _) do
    error
  end

  def cast(params, types) do
    type_keys = types |> Map.keys() |> Enum.map(&"#{&1}")

    initial =
      params
      |> Enum.map(fn
        {key, _value} when is_atom(key) ->
          {key, nil}

        {key, _value} when is_bitstring(key) ->
          (key in type_keys)
          |> case do
            true ->
              {key |> String.to_existing_atom(), nil}

            false ->
              nil
          end
      end)
      |> Enum.filter(& &1)
      |> Enum.into(%{})

    {initial, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> resolve_changeset
  end

  @spec validate(validate_params, Map.t()) :: validate_result
  def validate({:ok, params}, validations) do
    validate(params, validations)
  end

  def validate({:error, _} = error, _) do
    error
  end

  def validate(params, validations) do
    param_keys = for key <- params |> Map.keys(), do: {key, :any}, into: %{}
    validation_keys = for key <- validations |> Map.keys(), do: {key, :any}, into: %{}

    keys = Map.merge(param_keys, validation_keys)

    initial =
      params
      |> Enum.map(fn
        {key, _value} -> {key, nil}
      end)
      |> Enum.into(%{})

    changeset =
      {initial, keys}
      |> Ecto.Changeset.cast(params, keys |> Map.keys())

    validations
    |> Enum.reduce(changeset, &validate_changeset/2)
    |> resolve_changeset
  end

  defp resolve_changeset(changeset) do
    changeset
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> Ecto.Changeset.apply_changes()}

      changeset ->
        {:error, changeset}
    end
  end

  defp validate_changeset({key, key_validations}, changeset) when is_list(key_validations) do
    key_validations
    |> Enum.reduce(changeset, fn validation, changeset ->
      changeset
      |> do_validate(key, validation)
    end)
  end

  defp validate_changeset({key, key_validation}, changeset) do
    changeset
    |> do_validate(key, key_validation)
  end

  defp do_validate(changeset, key, :required) do
    changeset
    |> Ecto.Changeset.validate_required(key)
  end

  defp do_validate(changeset, key, fun) when is_function(fun) do
    changeset
    |> Ecto.Changeset.validate_change(key, fn _, value ->
      fun.(value)
      |> case do
        true -> []
        false -> [{key, "is invalid"}]
        nil -> []
        error -> [{key, error}]
      end
    end)
  end

  defp do_validate(changeset, _, _) do
    changeset
  end
end
