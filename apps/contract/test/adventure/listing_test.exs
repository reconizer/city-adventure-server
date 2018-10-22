defmodule Contract.Adventure.ListingTest do
  use ExUnit.Case, async: true
  alias Contract.Adventure.Listing

  describe "validate params to get adventure list" do
    
    test "params are valid" do
      validate_params = Listing.validate(%{"position" => %{lat: "52.9778169842329", lng: "18.764814285628727"}})
      assert {:ok, %Contract.Adventure.Listing{position: %Geo.Point{coordinates: {18.764814285628727, 52.9778169842329}, srid: 4326}}} == validate_params
    end

    test "params are invalid - params is nil" do
      validate_params = Listing.validate(%{})
      assert {:error, [position: {"can't be blank", [validation: :required]}]} == validate_params 
    end

    test "params are invalid - lat and lng is nil" do
      validate_params = Listing.validate(%{"position" => %{lat: nil, lng: nil}})
      assert {:error, [position: {"can't be blank", [validation: :required]}]} == validate_params 
    end

  end

end