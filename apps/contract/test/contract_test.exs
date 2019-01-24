defmodule ContractTest do
  use ExUnit.Case
  doctest Contract

  test "cast/2" do
    params = %{"foo" => "bar", "bar" => 2, "test" => [1, 2, 3, 4]}

    assert {:ok, _} = params |> Contract.cast(%{foo: :string, bar: :integer, test: {:array, :integer}})
    assert {:error, _} = params |> Contract.cast(%{bar: :string})
  end

  test "validate/2" do
    params = %{"foo" => 2}

    assert {:ok, _} = params |> Contract.validate(%{foo: :required})
    assert {:error, _} = params |> Contract.validate(%{bar: :required})

    assert {:ok, _} =
             params
             |> Contract.validate(%{
               foo: fn value ->
                 (value == 2)
                 |> case do
                   true -> nil
                   _ -> "invalid value"
                 end
               end
             })

    assert {:error, _} =
             params
             |> Contract.validate(%{
               foo: fn value ->
                 (value > 2)
                 |> case do
                   true -> nil
                   _ -> "must be greater than 2"
                 end
               end
             })

    assert {:error, _} =
             params
             |> Contract.validate(%{
               foo: fn value ->
                 value > 2
               end
             })

    assert {:ok, _} =
             params
             |> Contract.validate(%{
               foo: fn value ->
                 value >= 2
               end
             })
  end
end
