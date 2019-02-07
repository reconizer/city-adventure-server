defmodule Infrastructure.Repository.Migrations.AddUrlToClue do
  use Ecto.Migration

  def change do
    alter table(:clues) do
      add(:url, :text)
    end
  end
end
