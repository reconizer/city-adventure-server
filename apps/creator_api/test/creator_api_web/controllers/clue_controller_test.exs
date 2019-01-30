defmodule CreatorApiWeb.ClueControllerTest do
  use CreatorApiWeb.ConnCase, async: true
  alias CreatorApiWeb.Fixtures.Creator
  alias CreatorApiWeb.Fixtures.Adventure

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    creator_id = Ecto.UUID.generate()
    adventure_id = Ecto.UUID.generate()
    point_id = Ecto.UUID.generate()
    {:ok, _creator} = Creator.new(%{id: creator_id, email: "test@test.com", password: "testtest", name: "Test"})

    {:ok, adventure} =
      Adventure.new(%{id: adventure_id, creator_id: creator_id, name: "test adventure", position: %{lat: 70, lng: 80}})
      |> case do
        {:ok, %{points: [%{id: parent_point_id} | _]} = adventure} ->
          adventure
          |> Adventure.with_point(%{
            id: point_id,
            position: %{
              lat: 10,
              lng: 10
            },
            radius: 10,
            parent_point_id: parent_point_id,
            show: true
          })
      end
      |> Adventure.save()

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
    test "works", %{conn: conn, adventure_id: adventure_id, point_id: point_id} do
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

  describe "updating existing clue for adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id, point_id: point_id} do
      clue_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.with_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> Adventure.save()

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
    end
  end

  describe "get clue for adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id, point_id: point_id} do
      clue_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.with_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> Adventure.save()

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
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id, point_id: point_id} do
      clue_id = Ecto.UUID.generate()

      {:ok, _adventure} =
        adventure
        |> Adventure.with_clue(%{
          id: clue_id,
          point_id: point_id,
          type: ~w(text audio video image url) |> Enum.random(),
          description: "testtest",
          tip: [true, false] |> Enum.random()
        })
        |> Adventure.save()

      conn
      |> delete("/api/clues", %{"id" => clue_id, "adventure_id" => adventure_id})
      |> json_response(200)

      {:ok, adventure} = Adventure.get(adventure_id)

      assert {:error, _} =
               adventure
               |> Domain.Creator.Adventure.get_clue(clue_id)
    end
  end

  describe "reorder clues in adventure" do
    test "works", %{conn: conn, adventure: adventure, adventure_id: adventure_id, point_id: point_id} do
      clue_ids = for _ <- 0..4, do: Ecto.UUID.generate(), into: []

      other_point_id = Ecto.UUID.generate()

      {:ok, adventure} =
        clue_ids
        |> Enum.reduce(adventure, fn clue_id, adventure ->
          adventure
          |> Adventure.with_clue(%{
            id: clue_id,
            point_id: point_id,
            type: ~w(text audio video image url) |> Enum.random(),
            description: "testtest",
            tip: [true, false] |> Enum.random()
          })
        end)
        |> Adventure.with_point(%{
          id: other_point_id,
          position: %{
            lat: 10,
            lng: 10
          },
          parent_point_id: point_id,
          radius: 10,
          show: true
        })
        |> Adventure.save()

      clue_ids =
        adventure
        |> Domain.Creator.Adventure.get_point(point_id)
        |> Domain.Creator.Adventure.Point.get_clues()
        |> Enum.map(& &1.id)

      clue_order =
        clue_ids
        |> Enum.with_index()
        |> Enum.map(fn {clue_id, idx} ->
          %{
            "point_id" => [point_id, other_point_id] |> Enum.random(),
            "id" => clue_id,
            "sort" => idx
          }
        end)

      new_order =
        clue_order
        |> Enum.group_by(fn %{"point_id" => point_id} ->
          point_id
        end)
        |> IO.inspect()

      conn
      |> patch("/api/clues/reorder", %{"adventure_id" => adventure_id, "clue_order" => clue_order})
      |> json_response(200)

      {:ok, adventure} = Adventure.get(adventure_id)

      new_order
      |> Enum.each(fn {point_id, orders} ->
        point_clues =
          adventure
          |> Domain.Creator.Adventure.get_point(point_id)
          |> Domain.Creator.Adventure.Point.get_clues()
          |> Enum.map(& &1.id)
          |> Enum.reverse()

        order_clues = orders |> Enum.map(fn %{"id" => id} -> id end)

        assert point_clues == order_clues
      end)
    end
  end
end
