defmodule Domain.Adventure.Service.ResolvePoint do
  alias Domain.Adventure.Repository.Point, as: PointRepository
  alias Domain.Adventure.Repository.Answer, as: AnswerRepository

  def resolve_point(params, answers, user) do
    user_point = PointRepository.join_user_to_point(params, answers, user)
    result = AnswerRepository.resolve_clue(params, answers)
    result
    |> case do
      {:ok, :answer_correct} ->
        user_point
        |> PointRepository.update_point_as_completed()
      {:error, :wrong_answer} ->
        {:error, {:answer, "invalid"}}
      {:ok, :no_answer} ->
        {:ok, user_point} 
    end
  end

end