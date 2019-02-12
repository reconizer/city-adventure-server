defmodule Domain.Administration.UserTest do
  use ExUnit.Case, async: true
  alias Domain.Administration.User

  describe "new/2" do
    setup do
      valid_params = %{
        email: email = "Foo@bar.com",
        name: name = "test",
        password: "testtest"
      }

      [
        valid_params: valid_params,
        name: name,
        email: email
      ]
    end

    test "fails with invalid params" do
      assert {:error, _} = User.new(%{})
    end

    test "suceeds with valid params", %{email: email, name: name, valid_params: valid_params} do
      assert {:ok, %User{email: ^email, name: ^name}} = User.new(valid_params)
    end

    test "accepts touples", %{email: email, name: name, valid_params: valid_params} do
      assert {:error, "some error"} = User.new({:error, "some error"})
      assert {:ok, %User{email: ^email, name: ^name}} = User.new({:ok, valid_params})
    end

    test "emits event", %{valid_params: valid_params} do
      {:ok, user} = User.new(valid_params)

      assert [%{name: "Created"}] = user.events
    end
  end
end
