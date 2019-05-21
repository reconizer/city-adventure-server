defmodule CreatorApiWeb.ClueControllerTest do
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

  describe "creating new clue for adventure" do
    test "works", %{conn: conn, adventure_id: adventure_id, adventure: adventure} do
      %{points: [%{id: parent_point_id}]} = adventure
      point_id = Ecto.UUID.generate()

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

      clue_params = %{
        "adventure_id" => adventure_id,
        "point_id" => point_id,
        "type" => ~w(text audio video image url) |> Enum.random(),
        "description" => "testtest"
      }

      response =
        conn
        |> post("/api/clues", clue_params)
        |> json_response(200)

      assert %{
               "id" => _,
               "description" => "testtest",
               "order" => _,
               "point_id" => ^point_id,
               "tip" => _,
               "type" => _,
               "url" => _,
               "video_url" => _
             } = response
    end
  end

  describe "updating existing clue for adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure
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
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> AdventureRepository.save()

      clue_params = %{
        "id" => clue_id,
        "adventure_id" => adventure_id,
        "point_id" => point_id,
        "type" => ~w(text audio video image url) |> Enum.random(),
        "description" => "testtest"
      }

      conn
      |> patch("/api/clues", clue_params)
      |> json_response(200)

      {:ok, clue} =
        AdventureRepository.get(adventure_id)
        |> Adventure.get_clue(clue_id)

      assert %{
               id: ^clue_id,
               description: "testtest",
               point_id: ^point_id
             } = clue
    end
  end

  describe "get clue for adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

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
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> AdventureRepository.save()

      response =
        conn
        |> get("/api/clues/#{clue_id}", %{"adventure_id" => adventure_id})
        |> json_response(200)

      assert %{
               "id" => ^clue_id,
               "description" => _,
               "order" => _,
               "point_id" => ^point_id,
               "tip" => _,
               "type" => _,
               "url" => _,
               "video_url" => _
             } = response
    end
  end

  describe "delete clue from adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

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
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> AdventureRepository.save()

      conn
      |> delete("/api/clues", %{"id" => clue_id, "adventure_id" => adventure_id})
      |> json_response(200)

      assert {:error, _} =
               AdventureRepository.get(adventure_id)
               |> Adventure.get_clue(clue_id)
    end
  end

  describe "reorder clues in adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

      clue_ids = for _ <- 0..4, do: Ecto.UUID.generate(), into: []

      point_id = Ecto.UUID.generate()

      {:ok, adventure} =
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

      {:ok, adventure} =
        clue_ids
        |> Enum.reduce(adventure, fn clue_id, adventure ->
          adventure
          |> Adventure.add_clue(%{
            id: clue_id,
            point_id: point_id,
            type: ~w(text audio video image url) |> Enum.random(),
            description: "testtest",
            tip: [true, false] |> Enum.random()
          })
        end)
        |> AdventureRepository.save()

      clue_ids =
        adventure
        |> Adventure.get_point(point_id)
        |> Adventure.Point.get_clues()
        |> Enum.map(& &1.id)

      clue_order =
        clue_ids
        |> Enum.with_index()
        |> Enum.map(fn {clue_id, idx} ->
          %{
            "point_id" => [point_id, parent_point_id] |> Enum.random(),
            "id" => clue_id,
            "sort" => idx
          }
        end)

      new_order =
        clue_order
        |> Enum.group_by(fn %{"point_id" => point_id} ->
          point_id
        end)

      conn
      |> patch("/api/clues/reorder", %{"adventure_id" => adventure_id, "clue_order" => clue_order})
      |> json_response(200)

      {:ok, adventure} = AdventureRepository.get(adventure_id)

      new_order
      |> Enum.each(fn {point_id, orders} ->
        point_clues =
          adventure
          |> Adventure.get_point(point_id)
          |> Adventure.Point.get_clues()
          |> Enum.map(& &1.id)
          |> Enum.reverse()

        order_clues = orders |> Enum.map(fn %{"id" => id} -> id end)

        assert point_clues == order_clues
      end)
    end
  end

  describe "add asset to clue and generate upload url" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

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
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: "image",
          description: "testtest",
          tip: false
        })
        |> AdventureRepository.save()

      response =
        conn
        |> post("/api/clues/upload_asset", %{"clue_id" => clue_id, "adventure_id" => adventure.id, "extension" => "jpg", "name" => "name", "type" => "image"})
        |> json_response(200)

      assert %{"url" => _} = response
    end

    test "error - not clue", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

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

      response =
        conn
        |> post("/api/clues/upload_asset", %{"clue_id" => clue_id, "adventure_id" => adventure.id, "extension" => "jpg", "name" => "name", "type" => "image"})
        |> json_response(422)

      assert %{"clue_id" => "not found in adventure"} == response
    end

    test "error - not adventure", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      %{points: [%{id: parent_point_id}]} = adventure

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
        |> Adventure.add_clue(%{
          id: clue_id,
          point_id: point_id,
          type: "image",
          description: "testtest",
          tip: false
        })
        |> AdventureRepository.save()

      response =
        conn
        |> post("/api/clues/upload_asset", %{
          "clue_id" => clue_id,
          "adventure_id" => Ecto.UUID.generate(),
          "extension" => "jpg",
          "name" => "name",
          "type" => "image"
        })
        |> json_response(422)

      assert %{"adventure_id" => "not found in user"} == response
    end

    test "error - type can't be blank", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      clue_id = Ecto.UUID.generate()

      response =
        conn
        |> post("/api/clues/upload_asset", %{
          "clue_id" => clue_id,
          "adventure_id" => adventure.id,
          "extension" => "jpg",
          "name" => "name"
        })
        |> json_response(422)

      assert %{"type" => ["can't be blank"]} == response
    end

    test "error - type is invalid", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      clue_id = Ecto.UUID.generate()

      response =
        conn
        |> post("/api/clues/upload_asset", %{
          "clue_id" => clue_id,
          "adventure_id" => adventure.id,
          "extension" => "jpg",
          "name" => "name",
          "type" => "asds"
        })
        |> json_response(422)

      assert %{"type" => ["is invalid"]} == response
    end

    test "error - name can't be blank", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      clue_id = Ecto.UUID.generate()

      response =
        conn
        |> post("/api/clues/upload_asset", %{
          "clue_id" => clue_id,
          "adventure_id" => adventure.id,
          "extension" => "jpg",
          "type" => "image"
        })
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} == response
    end

    test "error - extension can't be blank", %{conn: conn, adventure: adventure, adventure_id: _adventure_id} do
      clue_id = Ecto.UUID.generate()

      response =
        conn
        |> post("/api/clues/upload_asset", %{
          "clue_id" => clue_id,
          "adventure_id" => adventure.id,
          "type" => "image",
          "name" => "name"
        })
        |> json_response(422)

      assert %{"extension" => ["can't be blank"]} == response
    end
  end
end
