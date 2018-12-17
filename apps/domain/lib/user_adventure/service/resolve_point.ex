defmodule Domain.UserAdventure.Service.ResolvePoint do

  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Adventure

  def resolve_point(adventure, params) do
    adventure 
    |> Adventure.add_user_point(params)
    |> Adventure.find_answer_type(params)
    |> Adventure.completed_adventure()
    # result = AnswerRepository.resolve_clue(params, answers)
    # result
    # |> case do
    #   {:ok, :answer_correct} ->
    #     user_point
    #     |> PointRepository.update_point_as_completed()
    #   {:error, :wrong_answer} ->
    #     {:error, {:answer, "invalid"}}
    #   {:ok, :no_answer} ->
    #     {:ok, user_point} 
    # end
  end

  def get_adventure(%{adventure_id: adventure_id}, user) do
    AdventureRepository.get(adventure_id, user) 
    |> case do
      nil -> {:error, {:adventure, "not_founds"}}
      result -> {:ok, result}
    end   
  end

end