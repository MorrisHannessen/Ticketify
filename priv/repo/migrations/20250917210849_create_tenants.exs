defmodule Ticketify.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string
      add :subdomain, :string
      add :description, :text
      add :email, :string
      add :phone, :string
      add :address, :text
      add :logo_url, :string
      add :status, :string
      add :settings, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tenants, [:subdomain])
  end
end
