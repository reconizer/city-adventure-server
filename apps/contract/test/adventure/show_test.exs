defmodule Cotract.Adventure.ShowTest do
    use ExUnit.Case, async: true
    alias Contract.Adventure.Show
  
    describe "validate params to get adventure" do
      
      test "params are valid" do
        uuid = Ecto.UUID.generate()
        validate_params = Show.validate(%{"id" => uuid})
        assert {:ok, %Contract.Adventure.Show{id: uuid}} == validate_params
      end
  
      test "params are invalid - params is nil" do
        validate_params = Show.validate(%{})
        assert {:error, [id: {"can't be blank", [validation: :required]}]} == validate_params 
      end
  
    end
  
  end