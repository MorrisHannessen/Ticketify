defmodule Ticketify.Repo.Migrations.AddTenantIdToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :tenant_id, references(:tenants, on_delete: :restrict), null: false
    end

    create index(:events, [:tenant_id])
    create unique_index(:events, [:slug, :tenant_id])
  end
end
