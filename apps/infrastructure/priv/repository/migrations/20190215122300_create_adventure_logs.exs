defmodule Infrastructure.Repository.Migrations.CreateAdventureLogs do
  use Ecto.Migration

  def up do
    """
    create or replace view adventure_logs as
    select id, content, adventure_id, administrator_id author_id, 'administrator_message' "type", inserted_at created_at from administrator_adventure_messages
    union
    select id, content, adventure_id, creator_id author_id, 'creator_message' "type", inserted_at created_at from creator_adventure_messages
    union
    select id, null "content", aggregate_id adventure_id, null author_id, (events.data->>'status') "type", created_at from events
    where aggregate_name = 'Creator.Adventure' and name = any(ARRAY['SentToReview', 'SentToPending'])
    union
    select id, null "content", aggregate_id adventure_id, null author_id, (events.data->>'status') "type", created_at from events
    where aggregate_name = 'AdventureReview.Adventure' and name = 'Changed' and (events.data->>'status') is not null
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
