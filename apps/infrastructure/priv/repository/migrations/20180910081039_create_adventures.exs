defmodule Infrastructure.Repository.Migrations.CreateAdventures do
  use Ecto.Migration

  def change do
    create table(:adventures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :estimated_time, :time
      add :difficulty_level, :integer
      add :published, :boolean
      add :show, :boolean
      add :language, :string
      add :code, :text

      timestamps()
    end

  end
end
