defmodule Ticketify.Tickets.Ticket do
  @moduledoc """
  Ticket schema representing individual digital tickets.

  Each ticket is associated with an order and contains a unique QR code
  for validation at event entry points.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(active used cancelled refunded)

  schema "tickets" do
    field :qr_code, :string
    field :status, :string, default: "active"
    field :scanned_at, :naive_datetime

    # Relationships
    belongs_to :order, Ticketify.Orders.Order
    belongs_to :ticket_type, Ticketify.Events.TicketType

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:qr_code, :status, :scanned_at])
    |> validate_inclusion(:status, @statuses)
    |> validate_length(:qr_code, min: 10, max: 255)
    |> unique_constraint(:qr_code)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:ticket_type_id)
  end

  @doc """
  Changeset for creating a new ticket with QR code generation
  """
  def create_changeset(ticket, attrs) do
    ticket
    |> changeset(attrs)
    |> put_change(:status, "active")
    |> generate_qr_code()
  end

  @doc """
  Changeset for scanning/using a ticket
  """
  def scan_changeset(ticket) do
    ticket
    |> change(
      status: "used",
      scanned_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
  end

  @doc """
  Changeset for cancelling a ticket
  """
  def cancel_changeset(ticket) do
    change(ticket, status: "cancelled")
  end

  defp generate_qr_code(changeset) do
    # Generate a unique QR code string
    qr_code =
      :crypto.strong_rand_bytes(16)
      |> Base.url_encode64()
      |> String.replace(~r/[^A-Za-z0-9]/, "")
      |> String.slice(0, 20)

    put_change(changeset, :qr_code, qr_code)
  end

  @doc """
  Checks if ticket is valid for scanning
  """
  def scannable?(%__MODULE__{status: "active"}), do: true
  def scannable?(_), do: false

  @doc """
  Checks if ticket has been used
  """
  def used?(%__MODULE__{status: "used"}), do: true
  def used?(_), do: false

  @doc """
  Checks if ticket is cancelled
  """
  def cancelled?(%__MODULE__{status: "cancelled"}), do: true
  def cancelled?(_), do: false

  @doc """
  Returns ticket display number
  """
  def ticket_number(%__MODULE__{id: id}) when is_integer(id) do
    "T#{String.pad_leading(Integer.to_string(id), 8, "0")}"
  end

  def ticket_number(_), do: nil

  @doc """
  Preloads associated data for ticket display
  """
  def with_associations(query \\ __MODULE__) do
    import Ecto.Query

    query
    |> preload([:order, ticket_type: :event])
  end
end
