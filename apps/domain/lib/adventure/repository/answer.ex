defmodule Domain.Adventure.Repository.Answer do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Infrastructure.Repository

  def check_answer_and_time([]), do: {:ok}
  def check_answer_and_time(answers) do
    answers
    |> IO.inspect
    |> Enum.filter(fn answer ->  
      answer.type == "time"
    end)
    |> case do
      nil -> {:ok}
      %{details: %{"starting_time" => starting_time, "duration" => duration}} ->
        time_now = Time.utc_now() |> Time.to_erl() |> :calendar.time_to_seconds()
        cond do
          starting_time <= time_now and time_now <= (starting_time + duration) ->
            {:ok}
          false -> {:error, :wrong_time}
        end
    end
  end

end