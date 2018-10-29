defmodule Domain.Adventure.Projections.Adventure do
  @moduledoc """
  Projection of adventure information
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :description, :min_time, :max_time, :difficulty_level, :language]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_adventure_by_id(%{id: adventure_id}) do
    from(adventure in Models.Adventure,
      left_join: image in Models.Image, on: [adventure_id: adventure.id],
      left_join: user_ranking in Models.UserRanking, on: user_ranking.adventure_id == adventure.id, limit: 5,
      select: %{
        id: adventure.id,
        description: adventure.description,
        name: adventure.name,
        min_time: adventure.min_time,
        max_time: adventure.max_time,
        difficulty_level: adventure.difficulty_level,
        language: adventure.language,
        image_ids: fragment("array_agg(?) filter(where ? IS NOT NULL)", image.id, image.id),
        top_five: fragment("array_agg((?, ?, ?, ?))", user_ranking.user_id, user_ranking.nick, user_ranking.position, user_ranking.completion_time)
      },
      where: adventure.published == true,
      where: adventure.id == ^adventure_id,
      group_by: [adventure.id]
    )
    |> Repository.one()
    |> case do
      nil -> {:error, {:adventure, "not_found"}}
      result -> {:ok, result}
    end
  end

end