defmodule Infrastructure.Repository.Migrations.CreateAdventureLogs do
  use Ecto.Migration

  def up do
    """
    create or replace view adventure_logs as
    select content, adventure_id, administrator_id author_id, 'administrator' author_type, inserted_at created_at from administrator_adventure_messages
    union
    select content, adventure_id, creator_id author_id, 'creator' author_type, inserted_at created_at from creator_adventure_messages
    union
    select (events.data->>'status') "content", aggregate_id adventure_id, null author_id, null author_type, created_at from events
    where aggregate_name = 'Creator.Adventure' and name = any(ARRAY['SentToReview', 'SentToPending'])
    union
    select (events.data->>'status') "content", aggregate_id adventure_id, null author_id, null author_type, created_at from events
    where aggregate_name = 'AdventureReview.Adventure' and name = any(ARRAY['SentToReview', 'SentToPending'])
    order by created_at desc
    """
    |> execute
  end

  def down do
    """
    DROP VIEW if exists adventure_logs;
    """
    |> execute
  end
end
