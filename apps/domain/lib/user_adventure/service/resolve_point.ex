defmodule Domain.UserAdventure.Service.ResolvePoint do

  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Adventure

  def resolve_point(adventure, params, user) do
    adventure 
    |> Adventure.add_user_point(params, user)
    |> Adventure.set_answer_type(params)
    |> Adventure.completed_adventure()
    |> Adventure.create_ranking(params)
  end

  def get_adventure(%{adventure_id: adventure_id}, user) do
    AdventureRepository.get(adventure_id, user) 
    |> case do
      nil -> {:error, {:adventure, "not_founds"}}
      result -> {:ok, result}
    end   
  end

end