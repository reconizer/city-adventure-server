defmodule Infrastructure.Repository.Migrations.ChangeCompletionTimeInRanking do
  use Ecto.Migration

  def change do
    alter table(:rankings) do
      remove :completion_time
      add :completion_time, :time
    end
  end
end
