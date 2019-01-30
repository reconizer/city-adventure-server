defmodule CreatorApiWeb.ClueControllerTest do
  use CreatorApiWeb.ConnCase
  alias CreatorApiWeb.Fixtures.Creator
  alias CreatorApiWeb.Fixtures.Adventure

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)
    creator_id = Ecto.UUID.generate()
    adventure_id = Ecto.UUID.generate()
    creator = Creator.new(%{id: creator_id, email: "test@test.com", password: "testtest", name: "Test"})
    adventure = Adventure.new(%{id: adventure_id, creator_id: creator_id, name: "test adventure", position: %{lat: 70, lng: 80}})

    [
      creator_id: id,
      adventure_id: adventure_id
    ]
  end

  describe "creating new clue for adventure" do
  end

  describe "updating existing clue for adventure" do
  end

  describe "get clue for adventure" do
  end

  describe "delete clue from adventure" do
  end

  describe "reorder clues in adventure" do
  end
end
