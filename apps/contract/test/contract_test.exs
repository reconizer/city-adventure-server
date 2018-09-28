defmodule ContractTest do
  use ExUnit.Case
  doctest Contract

  test "greets the world" do
    assert Contract.hello() == :world
  end
end
