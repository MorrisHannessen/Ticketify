defmodule Ticketify.TrackedObject do
  @moduledoc """
  TrackedObject provides timestamp and soft-delete functionality for all entities.

  Every entity in the system extends TrackedObject by using this module,
  which automatically adds:
  - `created_at` - when the record was first created
  - `updated_at` - when the record was last modified
  - `deleted_at` - when the record was soft-deleted (nil if active)

  ## Usage

  In your schema:

      defmodule MyApp.MySchema do
        use Ecto.Schema
        use Ticketify.TrackedObject

        schema "my_table" do
          field :name, :string
          # tracked fields (created_at, updated_at, deleted_at) are automatically added
        end
      end

  ## Soft Delete

  Records are never hard-deleted from the database. Instead, they are
  marked as deleted by setting the `deleted_at` timestamp.

  Use the provided query helpers to filter out deleted records:
  - `only_active/1` - returns only non-deleted records
  - `only_deleted/1` - returns only deleted records
  - `with_deleted/1` - returns all records (including deleted)
  """

  defmacro __using__(_opts) do
    quote do
      import Ecto.Changeset
      import Ticketify.TrackedObject, only: [tracked_timestamps: 0]

      @before_compile Ticketify.TrackedObject
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      # Add timestamp fields to the schema
      def __tracked_fields__ do
        [:created_at, :updated_at, :deleted_at]
      end
    end
  end

  @doc """
  Adds the tracked timestamp fields to a schema.
  Call this inside your schema block.
  """
  defmacro tracked_timestamps do
    quote do
      field :created_at, :utc_datetime
      field :updated_at, :utc_datetime
      field :deleted_at, :utc_datetime
    end
  end

  @doc """
  Puts created_at and updated_at timestamps on a changeset.
  Call this in your changesets when creating records.
  """
  def put_timestamps(changeset) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    changeset
    |> put_change(:updated_at, now)
    |> maybe_put_created_at(now)
  end

  defp maybe_put_created_at(changeset, now) do
    if changeset.data.__struct__.__struct__() == %Ecto.Schema.Metadata{} or
         is_nil(get_field(changeset, :created_at)) do
      put_change(changeset, :created_at, now)
    else
      changeset
    end
  end

  @doc """
  Marks a record as soft-deleted by setting deleted_at timestamp.
  """
  def soft_delete(changeset_or_struct) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    changeset_or_struct
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:deleted_at, now)
    |> Ecto.Changeset.put_change(:updated_at, now)
  end

  @doc """
  Restores a soft-deleted record by clearing the deleted_at timestamp.
  """
  def restore(changeset_or_struct) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    changeset_or_struct
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:deleted_at, nil)
    |> Ecto.Changeset.put_change(:updated_at, now)
  end

  @doc """
  Query helper to filter out soft-deleted records.
  Returns only active (non-deleted) records.

  ## Example

      Event
      |> TrackedObject.only_active()
      |> Repo.all()
  """
  def only_active(query) do
    import Ecto.Query
    where(query, [r], is_nil(r.deleted_at))
  end

  @doc """
  Query helper to get only soft-deleted records.

  ## Example

      Event
      |> TrackedObject.only_deleted()
      |> Repo.all()
  """
  def only_deleted(query) do
    import Ecto.Query
    where(query, [r], not is_nil(r.deleted_at))
  end

  @doc """
  Query helper that returns all records including deleted ones.
  This is the default Ecto behavior, but provided for clarity.

  ## Example

      Event
      |> TrackedObject.with_deleted()
      |> Repo.all()
  """
  def with_deleted(query), do: query

  @doc """
  Checks if a record is soft-deleted.
  """
  def deleted?(%{deleted_at: nil}), do: false
  def deleted?(%{deleted_at: _}), do: true

  @doc """
  Checks if a record is active (not deleted).
  """
  def active?(record), do: !deleted?(record)
end
