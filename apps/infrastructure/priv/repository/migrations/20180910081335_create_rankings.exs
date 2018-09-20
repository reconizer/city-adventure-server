defmodule Infrastructure.Repository.Migrations.CreateRankings do
  use Ecto.Migration

  def change do
    create table(:rankings, primary_key: false) do
      add :adventure_id, references(:adventures, [type: :uuid]), null: false
      add :user_id, references(:users, [type: :uuid]), null: false
      add :completion_time, :string
      timestamps()
    end
  end
end
