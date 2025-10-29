defmodule Ptc.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :url, :string
      add :tags, {:array, :string}, default: []
      add :start_date, :date
      add :end_date, :date
      add :is_paid, :boolean, default: false
      add :location, :string
      add :observation, :text

      timestamps()
    end
  end
end
