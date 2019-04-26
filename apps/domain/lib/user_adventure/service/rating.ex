defmodule Domain.UserAdventure.Service.Rating do
  @moduledoc """
  Service load rating for adventure
  """
  use Infrastructure.Repository.Models
  use Domain.Repository
  import Ecto.Query
  alias Infrastructure.Repository
  alias Domain.UserAdventure.Adventure

  def get_rating(%Adventure{} = adventure) do
    result =
      from(rating in Models.AdventureRating,
        select: %{
          rating_count: count(rating.user_id),
          rating: avg(rating.rating)
        },
        where: rating.adventure_id == ^adventure.id
      )
      |> Repository.one()
      |> load_rating()

    {:ok, result}
  end

  def load_rating(nil), do: nil

  def load_rating(result) do
    %{
      rating: parse_rating(result.rating),
      rating_count: result.rating_count
    }
  end

  defp parse_rating(nil), do: nil

  defp parse_rating(rating) do
    Decimal.to_float(rating) |> Float.round(2)
  end
end
