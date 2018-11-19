defmodule Infrastructure.Repository.Migrations.AddEndEstimatedTime do
  use Ecto.Migration

  def change do
    alter table(:adventures) do
      remove :estimated_time
      add :min_time, :time
      add :max_time, :time
    end

  end
end
