defmodule Ticketify.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :qr_code, :string
      add :status, :string
      add :scanned_at, :naive_datetime
      add :order_id, references(:orders, on_delete: :nothing)
      add :ticket_type_id, references(:ticket_types, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:order_id])
    create index(:tickets, [:ticket_type_id])
  end
end
