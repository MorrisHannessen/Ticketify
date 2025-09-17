defmodule Ticketify.Repo.Migrations.AddTenantIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :tenant_id, references(:tenants, on_delete: :restrict), null: false
    end

    create index(:users, [:tenant_id])
  end
end
