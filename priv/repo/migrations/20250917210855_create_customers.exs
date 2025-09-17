defmodule Ticketify.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :email, :string
      add :first_name, :string
      add :last_name, :string
      add :phone, :string
      add :date_of_birth, :date
      add :preferences, :map
      add :tenant_id, references(:tenants, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:customers, [:email])
    create index(:customers, [:tenant_id])
  end
end
