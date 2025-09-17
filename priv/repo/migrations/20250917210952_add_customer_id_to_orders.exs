defmodule Ticketify.Repo.Migrations.AddCustomerIdToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :customer_id, references(:customers, on_delete: :restrict)
      remove :user_id
    end

    create index(:orders, [:customer_id])
  end
end
