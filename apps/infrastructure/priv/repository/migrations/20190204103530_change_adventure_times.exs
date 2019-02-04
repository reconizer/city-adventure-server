defmodule Infrastructure.Repository.Migrations.ChangeAdventureTimes do
  use Ecto.Migration

  def change do
    alter table(:adventures) do
      remove(:min_time)
      add(:min_time, :integer)

      remove(:max_time)
      add(:max_time, :integer)
    end
  end
end
