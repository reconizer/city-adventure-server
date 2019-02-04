defmodule CreatorApiWeb.AdventureControllerTest do
  use CreatorApiWeb.ConnCase, async: true
  alias Domain.Creator.Adventure
  alias Domain.Creator.User

  alias Domain.Creator.Repository.Adventure, as: AdventureRepository
  alias Domain.Creator.Repository.User, as: UserRepository

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    creator_id = Ecto.UUID.generate()
    adventure_id = Ecto.UUID.generate()
    point_id = Ecto.UUID.generate()

    {:ok, _creator} =
      User.new(%{id: creator_id, email: "test@test.com", name: "Test"}, "testtest")
      |> UserRepository.save()

    {:ok, adventure} =
      Adventure.new(%{
        id: adventure_id,
        creator_id: creator_id,
        name: "test adventure",
        position: %{lat: 70, lng: 80}
      })
      |> AdventureRepository.save()

    token = CreatorApi.Token.create(creator_id)

    [
      creator_id: creator_id,
      point_id: point_id,
      adventure_id: adventure_id,
      token: token,
      adventure: adventure,
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

      response =
        conn
        |> post("/api/adventures", adventure_params)
        |> json_response(200)

      assert %{
               "name" => "Test adventure"
             } = response
    end
  end

  describe "updating existing adventure" do
    test "works", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        name: "Adventure",
        adventure_id: adventure_id,
        description: "FooBar",
        language: "PL",
        difficulty_level: 2,
        min_time: 15,
        max_time: 45,
        show: false
      }

      conn
      |> patch("/api/adventures", adventure_params)
      |> json_response(200)

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      assert %{
               name: "Adventure",
               description: "FooBar",
               language: "PL",
               difficulty_level: 2,
               min_time: 15,
               max_time: 45,
               show: false
             } = adventure
    end
  end

  describe "list adventures" do
    test "works", %{conn: conn, adventure_id: adventure_id} do
      response =
        conn
        |> get("/api/adventures")
        |> json_response(200)

      assert [
               %{
                 "id" => ^adventure_id,
                 "name" => "test adventure"
               }
             ] = response
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

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      assert %{
               status: "pending"
             } = adventure
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

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      assert %{
               status: "pending"
             } = adventure
    end

    test "works when sending to in review state", %{conn: conn, adventure_id: adventure_id} do
      adventure_params = %{
        "adventure_id" => adventure_id
      }

      conn
      |> post("/api/adventures/send_to_review", adventure_params)
      |> json_response(200)

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      assert %{
               status: "in_review"
             } = adventure
    end
  end
end
