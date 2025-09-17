defmodule Ticketify.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :text
      add :venue, :string
      add :address, :text
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
      add :capacity, :integer
      add :status, :string
      add :image_url, :string
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:events, [:slug])
  end
end
