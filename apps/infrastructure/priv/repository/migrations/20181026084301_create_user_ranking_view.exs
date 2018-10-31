defmodule Infrastructure.Repository.Migrations.CreateUserRankingView do
  use Ecto.Migration

  def up do
    """
    CREATE OR REPLACE VIEW public.user_ranking_view AS (
      SELECT
        rank() OVER (PARTITION BY ranking.adventure_id ORDER BY (EXTRACT(EPOCH FROM ranking.completion_time::time)) ASC, ranking.inserted_at ASC) AS "position",
        "user".nick AS nick,
        "user".id AS user_id,
        ranking.adventure_id AS adventure_id,
        EXTRACT(EPOCH FROM ranking.completion_time::time) AS completion_time
      FROM rankings ranking
      JOIN users "user" ON "user".id = ranking.user_id
      GROUP BY "user".id, ranking.user_id, ranking.adventure_id, ranking.completion_time, ranking.inserted_at 
    );
    """
    |> execute
  end

  def down do
    """
    DROP VIEW if exists public.user_ranking_view;
    """
    |> execute
  end
end
