defmodule AdministrationApiWeb.AuthControllerTest do
  use AdministrationApiWeb.ConnCase, async: true
  alias Domain.Administration.User

  alias Domain.Administration.User.Repository, as: UserRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    administrator_id = Ecto.UUID.generate()

    {:ok, _creator} =
      User.new(%{id: administrator_id, email: "test@test.com", name: "Test", password: "testtest"})
      |> UserRepository.save()

    :ok
  end

  describe "login/2" do
    @tag :integration
    test "succeeds with correct credentials", %{conn: conn} do
      params = %{
        "email" => "test@test.com",
        "password" => "testtest"
      }

      response =
        conn
        |> post("/api/auth/login", params)
        |> json_response(200)

      assert %{
               "token" => _
             } = response
    end

    @tag :integration
    test "fails with incorrect password", %{conn: conn} do
      params = %{
        "email" => "test@test.com",
        "password" => "testtest1"
      }

      response =
        conn
        |> post("/api/auth/login", params)
        |> json_response(422)

      assert %{"password" => ["invalid password"]} == response
    end

    @tag :integration
    test "fails with incorrect email", %{conn: conn} do
      params = %{
        "email" => "test@test.com1",
        "password" => "testtest1"
      }

      response =
        conn
        |> post("/api/auth/login", params)
        |> json_response(422)

      assert %{"email" => ["user not found"]} == response
    end
  end
end
