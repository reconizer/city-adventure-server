defmodule CreatorApiWeb.AdventureControllerTest do
  use CreatorApiWeb.ConnCase, async: true
  alias CreatorApiWeb.Fixtures.Creator
  alias CreatorApiWeb.Fixtures.Adventure

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)

    creator_id = Ecto.UUID.generate()
    adventure_id = Ecto.UUID.generate()

    {:ok, _creator} = Creator.new(%{id: creator_id, email: "test@test.com", password: "testtest", name: "Test"})
    {:ok, _adventure} = Adventure.new(%{id: adventure_id, creator_id: creator_id, name: "test adventure", position: %{lat: 70, lng: 80}}) |> Adventure.save()
    token = CreatorApi.Token.create(creator_id)

    [
      creator_id: creator_id,
      adventure_id: adventure_id,
      token: token,
      conn: conn |> put_req_header("authorization", token)
    ]
  end

  describe "creating new adventure" do
    test "works", %{conn: conn} do
      adventure_params = %{
        name: "Test adventure",
        position: %{
          lat: 80,
          lng: 70
        }
      }

      conn
      |> post("/api/adventures", adventure_params)
      |> json_response(200)
    end
  end

  describe "updating existing adventure" do
    test "works", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        name: "Test adventure",
        adventure_id: adventure_id
      }

      conn
      |> patch("/api/adventures", adventure_params)
      |> json_response(200)
    end
  end

  describe "list adventures" do
    test "works", %{conn: conn} do
      response =
        conn
        |> get("/api/adventures")
        |> json_response(200)

      assert response |> length == 1
    end
  end

  describe "get adventure" do
    test "works", %{conn: conn, adventure_id: adventure_id, creator_id: creator_id} do
      response =
        conn
        |> get("/api/adventures/#{adventure_id}")
        |> json_response(200)

      assert %{
               "cover_url" => _,
               "id" => ^adventure_id,
               "name" => _,
               "rating" => _,
               "shown" => _,
               "status" => _,
               "creator_id" => ^creator_id,
               "language" => _,
               "shown" => _,
               "status" => _,
               "images" => _,
               "description" => _,
               "duration" => _
             } = response
    end
  end

  describe "listing adventure statistics" do
    test "works", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        "adventure_id" => adventure_id
      }

      conn
      |> get("/api/adventures/statistics", adventure_params)
      |> json_response(200)
    end
  end

  describe "changing adventure state" do
    test "works when sending to pending state", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        "adventure_id" => adventure_id
      }

      conn
      |> post("/api/adventures/send_to_pending", adventure_params)
      |> json_response(422)
    end

    test "works when state is rejected", %{conn: conn, adventure_id: adventure_id} do
      Infrastructure.Repository.Models.Adventure
      |> Infrastructure.Repository.get(adventure_id)
      |> Infrastructure.Repository.Models.Adventure.changeset(%{
        status: "rejected"
      })
      |> Infrastructure.Repository.update()

      adventure_params = %{
        "adventure_id" => adventure_id
      }

      conn
      |> post("/api/adventures/send_to_pending", adventure_params)
      |> json_response(200)
    end

    test "works when sending to in review state", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        "adventure_id" => adventure_id
      }

      conn
      |> post("/api/adventures/send_to_review", adventure_params)
      |> json_response(200)
    end
  end
end
