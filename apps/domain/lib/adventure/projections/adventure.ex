defmodule Domain.Adventure.Projections.Adventure do
  @moduledoc """
  Projection of adventure information
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :description, :min_time, :max_time, :difficulty_level, :language]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_adventure_by_id(%{id: adventure_id}, %{id: owner_id}) do
    from(adventure in Models.Adventure,
      left_join: image in Models.Image, on: [adventure_id: adventure.id],
      left_join: owner_ranking in Models.UserRanking, on: [adventure_id: adventure.id, user_id: ^owner_id],
      left_join: user_ranking in Models.UserRanking, on: [adventure_id: adventure.id],
      select: %{
        id: adventure.id,
        description: adventure.description,
        name: adventure.name,
        min_time: fragment("EXTRACT(EPOCH FROM ?::time)::integer", adventure.min_time),
        max_time: fragment("EXTRACT(EPOCH FROM ?::time)::integer", adventure.max_time),
        difficulty_level: adventure.difficulty_level,
        language: adventure.language,
        image_ids: fragment("array_agg(?) filter(where ? IS NOT NULL)", image.id, image.id),
        top_five: fragment("array_agg((?::text, ?, ?, ?)) filter(where ? <= 5)", user_ranking.user_id, user_ranking.position, user_ranking.completion_time, user_ranking.nick, user_ranking.position),
        owner_ranking: %{
          user_id: owner_ranking.user_id, 
          position: owner_ranking.position, 
          completion_time: owner_ranking.completion_time,
          nick: owner_ranking.nick
        } 
      },
      where: adventure.published == true,
      where: adventure.id == ^adventure_id,
      group_by: [adventure.id, owner_ranking.user_id, owner_ranking.position, owner_ranking.nick, owner_ranking.completion_time]
    )
    |> Repository.one()
    |> case do
      nil -> {:error, {:adventure, "not_found"}}
      result -> {:ok, result}
    end
  end

end