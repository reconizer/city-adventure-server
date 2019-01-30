defmodule CreatorApiWeb.AuthControllerTest do
  use CreatorApiWeb.ConnCase, async: true
  alias CreatorApiWeb.Fixtures.Creator

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
  end

  describe "login" do
    setup do
      Creator.new(%{id: Ecto.UUID.generate(), email: "test@test.com", password: "testtest", name: "Foobar"})
      :ok
    end

    test "login/2", %{conn: conn} do
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
  end

  describe "register" do
    test "register/2", %{conn: conn} do
      params = %{
        "email" => "user2@email.com",
        "password" => "testtest",
        "name" => "testtest"
      }

      response =
        conn
        |> post("/api/auth/register", params)
        |> json_response(200)

      assert %{} = response
    end
  end
end
