defmodule AdministrationApiWeb.PointControllerTest do
  use AdministrationApiWeb.ConnCase, async: true
  alias Domain.Creator.Adventure
  alias Domain.Administration.User, as: Administrator
  alias Domain.Creator.User, as: Creator

  alias Domain.Creator.Repository.Adventure, as: AdventureRepository
  alias Domain.Administration.User.Repository, as: AdministratorUserRepository
  alias Domain.Creator.Repository.User, as: CreatorUserRepository

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    creator_id = Ecto.UUID.generate()
    administrator_id = Ecto.UUID.generate()
    adventure_id = Ecto.UUID.generate()
    point_id = Ecto.UUID.generate()

    {:ok, _} =
      Creator.new(%{id: creator_id, email: "test@test.com", name: "Test"}, "testtest")
      |> CreatorUserRepository.save()

    {:ok, _} =
      Administrator.new(%{id: administrator_id, email: "test@test.com", name: "Test", password: "testtest"})
      |> AdministratorUserRepository.save()

    {:ok, adventure} =
      Adventure.new(%{
        id: adventure_id,
        creator_id: creator_id,
        name: "test adventure",
        position: %{lat: 70, lng: 80}
      })
      |> AdventureRepository.save()

    {:ok, token} = AdministrationApi.Token.create(creator_id)

    [
      administrator_id: administrator_id,
      creator_id: creator_id,
      point_id: point_id,
      adventure_id: adventure_id,
      token: token,
      adventure: adventure,
      conn: conn |> put_req_header("authorization", token)
    ]
  end

  describe "creating new point" do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      {:ok, %{id: last_point_id}} = adventure |> Adventure.get_last_point()

      point_params = %{
        "adventure_id" => adventure_id,
        "parent_point_id" => last_point_id,
        "position" => %{
          "lat" => 123,
          "lng" => 12
        }
      }

      response =
        conn
        |> post("/api/points", point_params)
        |> json_response(200)

      assert %{
               "clues" => _,
               "id" => _,
               "parent_id" => ^last_point_id,
               "password_answer" => _,
               "position" => %{"lat" => 123.0, "lng" => 12.0},
               "radius" => _,
               "shown" => _,
               "time_answer" => _
             } = response
    end
  end

  describe "updating existing point" do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      {:ok, %{id: parent_point_id}} = adventure |> Adventure.get_last_point()
      point_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.add_point(%{
          id: point_id,
          parent_point_id: parent_point_id,
          position: %{
            lat: 10,
            lng: 10
          },
          radius: 10,
          show: false
        })
        |> AdventureRepository.save()

      point_params = %{
        "id" => point_id,
        "adventure_id" => adventure_id,
        "parent_point_id" => parent_point_id,
        "position" => %{
          "lat" => 50,
          "lng" => 60
        },
        "radius" => 20,
        "show" => true,
        "time_answer" => %{
          "start_time" => 50,
          "duration" => 30
        },
        "password_answer" => %{
          "type" => "text",
          "password" => "1234"
        }
      }

      conn
      |> patch("/api/points", point_params)
      |> json_response(200)

      {:ok, point} =
        AdventureRepository.get(adventure_id)
        |> Adventure.get_point(point_id)

      assert %{
               clues: [],
               id: point_id,
               parent_point_id: parent_point_id,
               password_answer: %{
                 password: "1234",
                 type: "text"
               },
               position: %{
                 lat: 50.0,
                 lng: 60.0
               },
               radius: 20,
               show: true,
               time_answer: %{
                 duration: 30,
                 start_time: 50
               }
             } = point
    end
  end

  describe "listing points for adventure" do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id} do
      point_params = %{
        "adventure_id" => adventure_id
      }

      response =
        conn
        |> get("/api/points", point_params)
        |> json_response(200)

      assert response |> length == 1
    end
  end

  describe "list point for adventure" do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      {:ok, %{id: parent_point_id}} = adventure |> Adventure.get_last_point()
      point_id = Ecto.UUID.generate()
      clue_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.add_point(%{
          id: point_id,
          parent_point_id: parent_point_id,
          position: %{
            lat: 10,
            lng: 10
          },
          radius: 10,
          show: false
        })
        |> AdventureRepository.save()
        |> Adventure.change_point(%{
          id: point_id,
          time_answer: %{
            start_time: 55,
            duration: 66
          },
          password_answer: %{
            type: "text",
            password: "1234"
          }
        })
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: "url",
          description: "test",
          tip: true
        })
        |> AdventureRepository.save()

      point_params = %{
        "adventure_id" => adventure_id
      }

      response =
        conn
        |> get("/api/points/#{point_id}", point_params)
        |> json_response(200)

      assert %{
               "clues" => [
                 %{
                   "description" => "test",
                   "id" => ^clue_id,
                   "order" => 0,
                   "point_id" => ^point_id,
                   "tip" => true,
                   "type" => "url",
                   "url" => nil,
                   "video_url" => nil
                 }
               ],
               "id" => ^point_id,
               "parent_id" => ^parent_point_id,
               "password_answer" => %{
                 "type" => "text",
                 "password" => "1234"
               },
               "position" => %{"lat" => 10.0, "lng" => 10.0},
               "radius" => 10,
               "shown" => false,
               "time_answer" => %{
                 "start_time" => 55,
                 "duration" => 66
               }
             } = response
    end
  end

  describe "delete point from adventure" do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      {:ok, %{id: parent_point_id}} = adventure |> Adventure.get_last_point()
      point_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.add_point(%{
          id: point_id,
          parent_point_id: parent_point_id,
          position: %{
            lat: 10,
            lng: 10
          },
          radius: 10,
          show: false
        })
        |> AdventureRepository.save()

      point_params = %{
        "adventure_id" => adventure_id,
        "id" => point_id
      }

      conn
      |> delete("/api/points", point_params)
      |> json_response(200)

      {:error, _} =
        AdventureRepository.get(adventure_id)
        |> Adventure.get_point(point_id)
    end
  end

  describe("reorder points in adventure") do
    @tag :integration

    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      {:ok, %{id: parent_point_id}} = adventure |> Adventure.get_last_point()

      point_ids = for _ <- 0..5, do: Ecto.UUID.generate(), into: []

      points =
        point_ids
        |> Enum.reduce([{Ecto.UUID.generate(), parent_point_id}], fn point_id, [{last_point_id, _} | _] = points ->
          [{point_id, last_point_id} | points]
        end)
        |> Enum.reverse()

      {:ok, adventure} =
        points
        |> Enum.reduce(adventure, fn {point_id, parent_point_id}, adventure ->
          adventure
          |> Adventure.add_point(%{
            id: point_id,
            parent_point_id: parent_point_id,
            position: %{
              lat: 10,
              lng: 10
            },
            radius: 10,
            show: false
          })
        end)
        |> AdventureRepository.save()

      points_before =
        adventure.points
        |> Enum.map(& &1.id)

      [first_point_id | rest_points] = points_before

      points =
        rest_points
        |> Enum.shuffle()
        |> Enum.with_index()
        |> Enum.reduce([], fn
          {point_id, 0}, _ = points -> [{point_id, first_point_id} | points]
          {point_id, _}, [{last_point_id, _} | _] = points -> [{point_id, last_point_id} | points]
        end)
        |> Enum.reverse()

      point_order =
        points
        |> Enum.map(fn {point_id, parent_point_id} ->
          %{
            id: point_id,
            parent_point_id: parent_point_id
          }
        end)

      point_params = %{
        "adventure_id" => adventure_id,
        "point_order" => point_order
      }

      conn
      |> patch("/api/points/reorder", point_params)
      |> json_response(200)

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      assert adventure.points
             |> Enum.map(& &1.id) == [first_point_id | point_order |> Enum.map(& &1.id)]
    end
  end
end
