defmodule Ticketify.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :total_amount, :decimal
      add :status, :string
      add :customer_email, :string
      add :customer_first_name, :string
      add :customer_last_name, :string
      add :customer_phone, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
  end
end
