defmodule Ticketify.Events.Event do
  @moduledoc """
  Event schema representing festivals and events.

  Events belong to tenants and contain ticket types, capacity limits,
  and scheduling information.
  """
  use Ecto.Schema
  use Ticketify.TrackedObject
  import Ecto.Changeset

  @statuses ~w(draft published active completed cancelled)

  schema "events" do
    field :name, :string
    field :description, :string
    field :venue, :string
    field :address, :string
    field :start_date, :naive_datetime
    field :end_date, :naive_datetime
    field :capacity, :integer
    field :status, :string, default: "draft"
    field :image_url, :string
    field :slug, :string

    # Relationships
    belongs_to :tenant, Ticketify.Tenants.Tenant
    has_many :ticket_types, Ticketify.Events.TicketType, on_delete: :delete_all

    # Tracked object fields (created_at, updated_at, deleted_at)
    tracked_timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :description,
      :venue,
      :address,
      :start_date,
      :end_date,
      :capacity,
      :status,
      :image_url
    ])
    |> validate_required([
      :name,
      :description,
      :venue,
      :address,
      :start_date,
      :end_date,
      :capacity
    ])
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:capacity, greater_than: 0)
    |> validate_dates()
    |> generate_slug()
    |> unique_constraint([:slug, :tenant_id])
  end

  defp validate_dates(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      start_date && end_date && NaiveDateTime.compare(start_date, end_date) != :lt ->
        add_error(changeset, :end_date, "must be after start date")

      start_date && NaiveDateTime.compare(start_date, NaiveDateTime.utc_now()) == :lt ->
        add_error(changeset, :start_date, "must be in the future")

      true ->
        changeset
    end
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil ->
        changeset

      name ->
        slug =
          name
          |> String.downcase()
          |> String.replace(~r/[^\w\s]/, "")
          |> String.replace(~r/\s+/, "-")
          |> String.trim("-")

        put_change(changeset, :slug, slug)
    end
  end

  @doc """
  Returns total tickets sold for this event
  """
  def tickets_sold(event) do
    event
    |> Ecto.assoc(:ticket_types)
    |> Ticketify.Repo.all()
    |> Enum.reduce(0, fn ticket_type, acc ->
      acc + (ticket_type.capacity - ticket_type.available)
    end)
  end

  @doc """
  Checks if event is active (published and within date range)
  """
  def active?(%__MODULE__{status: "active", start_date: start_date, end_date: end_date}) do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(now, start_date) != :lt && NaiveDateTime.compare(now, end_date) == :lt
  end

  def active?(_), do: false
end
