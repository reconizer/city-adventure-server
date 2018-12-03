defmodule Infrastructure.Repository.Migrations.AddPositionToUserPoint do
  use Ecto.Migration

  def change do
    alter table(:user_points) do
      add :position, :geometry
    end
  end
end
