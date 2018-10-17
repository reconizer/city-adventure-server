defmodule Seed.Adventure do
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Ecto.Multi
  
  def seed() do
    Multi.new()
    |> Multi.insert(:adventure, build_adventure(), returning: true)
  end

  defp build_adventure do
    
  end

end