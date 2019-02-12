defmodule Infrastructure.Repository.Migrations.ChangeRankingCompletionTime do
  use Ecto.Migration

  defmodule Infrastructure.Repository.Migrations.ChangeAdventureTimes do
    use Ecto.Migration

    def change do
      """
      DROP VIEW if exists public.user_ranking_view;
      """
      |> execute

      """

      ALTER TABLE public.rankings DROP COLUMN completion_time;
      """
      |> execute

      """
      ALTER TABLE public.rankings ADD COLUMN completion_time integer;
      """
      |> execute

      """
      CREATE OR REPLACE VIEW public.user_ranking_view AS (
        SELECT
        row_number() OVER (PARTITION BY ranking.adventure_id ORDER BY ranking.completion_time::integer ASC, ranking.inserted_at ASC) AS "position",
          "user".nick AS nick,
          "user".id AS user_id,
          ranking.adventure_id AS adventure_id,
          ranking.completion_time::integer AS completion_time
        FROM rankings ranking
        JOIN users "user" ON "user".id = ranking.user_id
        GROUP BY "user".id, ranking.user_id, ranking.adventure_id, ranking.completion_time, ranking.inserted_at 
      );
      """
      |> execute
    end
  end
end
