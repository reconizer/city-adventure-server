defmodule Infrastructure.Repository.Migrations.CreateAdventureRatingView do
  use Ecto.Migration

  def up do
    """
    CREATE OR REPLACE VIEW public.adventure_rating_view AS (
      SELECT
        rating.adventure_id AS adventure_id,
        AVG(rating.rating) AS rating
      FROM adventure_ratings rating
      GROUP BY rating.adventure_id
    );
    """
    |> execute
  end

  def down do
    """
    DROP VIEW if exists public.adventure_rating_view;
    """
    |> execute
  end
end
