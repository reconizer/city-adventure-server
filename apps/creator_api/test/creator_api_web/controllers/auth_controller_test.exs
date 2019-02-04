defmodule CreatorApiWeb.AuthControllerTest do
  use CreatorApiWeb.ConnCase, async: true
  alias Domain.Creator.User

  alias Domain.Creator.Repository.User, as: UserRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    creator_id = Ecto.UUID.generate()

    {:ok, _creator} =
      User.new(%{id: creator_id, email: "test@test.com", name: "Test"}, "testtest")
      |> UserRepository.save()

    :ok
  end

  describe "login" do
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

      conn
      |> post("/api/auth/register", params)
      |> json_response(200)

      {:ok, user} = UserRepository.get_by_email_and_password("user2@email.com", "testtest")

      assert %{
               email: "user2@email.com",
               name: "testtest"
             } = user
    end
  end
end
