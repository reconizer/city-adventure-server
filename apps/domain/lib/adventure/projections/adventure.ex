defmodule Domain.Adventure.Projections.Adventure do
  @moduledoc """
  Projection of adventure information
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :description, :estimated_time, :difficulty_level, :language]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_adventure_by_id(%{id: adventure_id}) do
    from(adventure in Models.Adventure,
      left_join: image in Models.Image, on: [adventure_id: adventure.id],
      select: %{
        id: adventure.id,
        description: adventure.description,
        name: adventure.name,
        min_time: adventure.min_time,
        max_time: adventure.max_time,
        difficulty_level: adventure.difficulty_level,
        language: adventure.language,
        image_ids: fragment("array_agg(?)", image.id)
      },
      where: adventure.published == true,
      where: adventure.id == ^adventure_id,
      group_by: adventure.id
    )
    |> Repository.one()
    |> case do
      nil -> {:error, {:adventure, "not_found"}}
      result -> {:ok, result}
    end
  end

end