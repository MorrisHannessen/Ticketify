defmodule Ticketify.Repo.Migrations.CreateTicketTypes do
  use Ecto.Migration

  def change do
    create table(:ticket_types) do
      add :name, :string
      add :description, :text
      add :price, :decimal
      add :capacity, :integer
      add :available, :integer
      add :event_id, references(:events, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:ticket_types, [:event_id])
  end
end
