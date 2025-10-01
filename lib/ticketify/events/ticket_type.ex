defmodule Ticketify.Events.TicketType do
  @moduledoc """
  TicketType schema representing different categories of tickets for an event.

  Each event can have multiple ticket types with different prices,
  capacities, and availability periods.
  """
  use Ecto.Schema
  use Ticketify.TrackedObject
  import Ecto.Changeset

  schema "ticket_types" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :capacity, :integer
    field :available, :integer

    # Relationships
    belongs_to :event, Ticketify.Events.Event
    has_many :tickets, Ticketify.Tickets.Ticket, on_delete: :delete_all

    # Tracked object fields (created_at, updated_at, deleted_at)
    tracked_timestamps()
  end

  @doc false
  def changeset(ticket_type, attrs) do
    ticket_type
    |> cast(attrs, [:name, :description, :price, :capacity, :available])
    |> validate_required([:name, :description, :price, :capacity])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:capacity, greater_than: 0)
    |> validate_available_tickets()
    |> foreign_key_constraint(:event_id)
  end

  defp validate_available_tickets(changeset) do
    capacity = get_field(changeset, :capacity)
    available = get_field(changeset, :available)

    cond do
      available && capacity && available > capacity ->
        add_error(changeset, :available, "cannot exceed capacity")

      available && available < 0 ->
        add_error(changeset, :available, "cannot be negative")

      true ->
        changeset
    end
  end

  @doc """
  Sets available tickets to capacity when creating a new ticket type
  """
  def create_changeset(ticket_type, attrs) do
    changeset = changeset(ticket_type, attrs)
    capacity = get_field(changeset, :capacity)

    if capacity do
      put_change(changeset, :available, capacity)
    else
      changeset
    end
  end

  @doc """
  Decreases available ticket count
  """
  def reserve_tickets(ticket_type, count) when count > 0 do
    if ticket_type.available >= count do
      change(ticket_type, available: ticket_type.available - count)
    else
      ticket_type
      |> change()
      |> add_error(:available, "not enough tickets available")
    end
  end

  @doc """
  Increases available ticket count (for cancellations)
  """
  def release_tickets(ticket_type, count) when count > 0 do
    new_available = min(ticket_type.available + count, ticket_type.capacity)
    change(ticket_type, available: new_available)
  end

  @doc """
  Checks if tickets are available for purchase
  """
  def available?(%__MODULE__{available: available}) when available > 0, do: true
  def available?(_), do: false

  @doc """
  Returns the number of sold tickets
  """
  def sold_count(%__MODULE__{capacity: capacity, available: available}) do
    capacity - available
  end
end
