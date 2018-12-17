defmodule Domain.UserAdventure.Repository.Answer do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models

  # def check_answer_and_time([]), do: {:ok}
  # def check_answer_and_time(answers) do
  #   answers
  #   |> Enum.filter(fn answer ->  
  #     answer.type == "time"
  #   end)
  #   |> List.first()
  #   |> case do
  #     nil -> {:ok, true}
  #     %{details: %{"starting_time" => starting_time, "duration" => duration}} ->
  #       time_now = Time.utc_now() |> Time.to_erl() |> :calendar.time_to_seconds()
  #       cond do
  #         starting_time <= time_now and time_now <= (starting_time + duration) ->
  #           {:ok, true}
  #         false -> {:error, :wrong_time}
  #       end
  #   end
  # end

  # def find_answer_type(answers), do: {:ok, find_answer_type!(answers)}
  # def find_answer_type!(answers) do
  #   answers
  #   |> case do
  #     [] -> nil 
  #     result ->
  #       %{details: %{"password_type" => type}} = result
  #       |> Enum.filter(fn answer -> 
  #         answer.type == "password"
  #       end)
  #       |> List.first()
  #       type
  #   end
  # end

  # def resolve_clue(%{answer_text: nil, answer_type: nil}, _answers), do: {:ok, :no_answer}
  # def resolve_clue(%{answer_text: answer_text, answer_type: answer_type}, answers) do
  #   answers
  #   |> Enum.filter(fn %{details: %{"password" => password, "password_type" => type}} -> 
  #     password == answer_text and type == answer_type
  #   end)
  #   |> case do 
  #     [] -> {:error, :wrong_answer}
  #     _result -> {:ok, :answer_correct} 
  #   end
  # end

end