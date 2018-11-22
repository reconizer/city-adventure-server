defmodule Cotract.Adventure.ClueListingTest do
    use ExUnit.Case, async: true
    alias Contract.Adventure.ClueListing
  
    describe "validate params to get clues for adventure" do
      
      test "params are valid" do
        uuid = Ecto.UUID.generate()
        validate_params = ClueListing.validate(%{"adventure_id" => uuid})
        assert {:ok, %Contract.Adventure.ClueListing{adventure_id: uuid}} == validate_params
      end
  
      test "params are invalid - params is nil" do
        validate_params = ClueListing.validate(%{})
        assert {:error, [adventure_id: {"can't be blank", [validation: :required]}]} == validate_params 
      end
  
    end
  
  end