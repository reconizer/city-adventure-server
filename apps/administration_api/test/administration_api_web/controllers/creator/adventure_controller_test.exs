defmodule AdministrationApiWeb.Creator.AdventureControllerTest do
  use AdministrationApiWeb.ConnCase, async: true
  alias Domain.Administration.User
  alias Domain.Administration.User.Repository, as: UserRepository

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    administrator_id = Ecto.UUID.generate()

    {:ok, administrator} =
      User.new(%{id: administrator_id, email: "test@test.com", name: "Test", password: "testtest"})
      |> UserRepository.save()

    {:ok, token} = AdministrationApi.Token.create(administrator.id)

    [
      adventure_id: Ecto.UUID.generate(),
      token: token,
      unauthorized_conn: conn,
      conn: conn |> put_req_header("authorization", token)
    ]
  end

  describe "list/2" do
    test "fails with incorrect credentials", %{unauthorized_conn: unauthorized_conn} do
      response =
        unauthorized_conn
        |> get("/api/creator/adventures")
        |> json_response(401)

      assert %{} = response
    end

    test "succeeds with correct params", %{conn: conn} do
      response =
        conn
        |> get("/api/creator/adventures")
        |> json_response(200)

      assert %{} = response
    end
  end

  describe "get/2" do
    test "fails with incorrect credentials", %{unauthorized_conn: unauthorized_conn, adventure_id: adventure_id} do
      response =
        unauthorized_conn
        |> get("/api/creator/adventures/#{adventure_id}")
        |> json_response(401)

      assert %{} = response
    end

    test "succeeds with correct params", %{conn: conn, adventure_id: adventure_id} do
      response =
        conn
        |> get("/api/creator/adventures/#{adventure_id}")
        |> json_response(200)

      assert %{} = response
    end
  end
end
