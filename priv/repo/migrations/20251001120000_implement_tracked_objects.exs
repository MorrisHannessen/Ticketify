defmodule Ticketify.Repo.Migrations.ImplementTrackedObjects do
  @moduledoc """
  Implements tracked object pattern across all entities.

  This migration:
  1. Removes old inserted_at and updated_at fields from all tables
  2. Adds new created_at, updated_at, and deleted_at fields
  3. Migrates existing timestamp data to new fields

  The new pattern provides:
  - Consistent naming (created_at instead of inserted_at)
  - Soft delete support (deleted_at)
  - Better tracking capabilities
  """
  use Ecto.Migration

  def up do
    # List of all tables that need tracked object fields
    tables = [
      "tenants",
      "users",
      "customers",
      "events",
      "ticket_types",
      "orders",
      "tickets"
    ]

    # For each table, add new fields and migrate data
    Enum.each(tables, fn table ->
      # Add new tracked object fields
      alter table(table) do
        add :created_at, :utc_datetime
        add :deleted_at, :utc_datetime
      end

      # Migrate inserted_at to created_at (preserve existing timestamps)
      execute """
      UPDATE #{table}
      SET created_at = inserted_at
      WHERE inserted_at IS NOT NULL
      """

      # Make created_at and updated_at non-nullable
      alter table(table) do
        modify :created_at, :utc_datetime, null: false
        modify :updated_at, :utc_datetime, null: false
      end

      # Remove old timestamp fields
      alter table(table) do
        remove :inserted_at
      end
    end)
  end

  def down do
    # List of all tables that need to revert
    tables = [
      "tenants",
      "users",
      "customers",
      "events",
      "ticket_types",
      "orders",
      "tickets"
    ]

    # Revert changes for each table
    Enum.each(tables, fn table ->
      # Add back inserted_at
      alter table(table) do
        add :inserted_at, :utc_datetime
      end

      # Migrate created_at back to inserted_at
      execute """
      UPDATE #{table}
      SET inserted_at = created_at
      WHERE created_at IS NOT NULL
      """

      # Make inserted_at non-nullable
      alter table(table) do
        modify :inserted_at, :utc_datetime, null: false
      end

      # Remove tracked object fields
      alter table(table) do
        remove :created_at
        remove :deleted_at
      end
    end)
  end
end
