defmodule Ticketify.Tickets do
  @moduledoc """
  The Tickets context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Tickets.Ticket

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
  def list_tickets do
    Repo.all(Ticket)
  end

  @doc """
  Returns the list of tickets for an order.

  ## Examples

      iex> list_order_tickets(order_id)
      [%Ticket{}, ...]

  """
  def list_order_tickets(order_id) do
    Ticket
    |> where([t], t.order_id == ^order_id)
    |> preload(ticket_type: :event)
    |> Repo.all()
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(id), do: Repo.get!(Ticket, id)

  @doc """
  Gets a ticket by QR code.

  ## Examples

      iex> get_ticket_by_qr_code("ABC123XYZ")
      %Ticket{}

      iex> get_ticket_by_qr_code("invalid")
      nil

  """
  def get_ticket_by_qr_code(qr_code) do
    Ticket
    |> where([t], t.qr_code == ^qr_code)
    |> preload([:order, ticket_type: :event])
    |> Repo.one()
  end

  @doc """
  Gets a ticket with all associations preloaded.

  ## Examples

      iex> get_ticket_with_associations!(123)
      %Ticket{ticket_type: %TicketType{event: %Event{}}, order: %Order{}}

  """
  def get_ticket_with_associations!(id) do
    Ticket
    |> where([t], t.id == ^id)
    |> Ticket.with_associations()
    |> Repo.one!()
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Scans a ticket (marks it as used).

  ## Examples

      iex> scan_ticket(ticket)
      {:ok, %Ticket{}}

      iex> scan_ticket(used_ticket)
      {:error, %Ecto.Changeset{}}

  """
  def scan_ticket(%Ticket{} = ticket) do
    if Ticket.scannable?(ticket) do
      ticket
      |> Ticket.scan_changeset()
      |> Repo.update()
    else
      {:error, :ticket_not_scannable}
    end
  end

  @doc """
  Scans a ticket by QR code.

  ## Examples

      iex> scan_ticket_by_qr_code("ABC123XYZ")
      {:ok, %Ticket{}}

      iex> scan_ticket_by_qr_code("invalid")
      {:error, :ticket_not_found}

  """
  def scan_ticket_by_qr_code(qr_code) do
    case get_ticket_by_qr_code(qr_code) do
      nil ->
        {:error, :ticket_not_found}

      ticket ->
        scan_ticket(ticket)
    end
  end

  @doc """
  Cancels a ticket.

  ## Examples

      iex> cancel_ticket(ticket)
      {:ok, %Ticket{}}

  """
  def cancel_ticket(%Ticket{} = ticket) do
    ticket
    |> Ticket.cancel_changeset()
    |> Repo.update()
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset(ticket, attrs)
  end

  @doc """
  Returns statistics for tickets.

  ## Examples

      iex> get_ticket_stats()
      %{total: 1000, active: 800, used: 150, cancelled: 50}

  """
  def get_ticket_stats do
    stats =
      Ticket
      |> group_by([t], t.status)
      |> select([t], {t.status, count(t.id)})
      |> Repo.all()
      |> Enum.into(%{})

    %{
      total: Enum.sum(Map.values(stats)),
      active: Map.get(stats, "active", 0),
      used: Map.get(stats, "used", 0),
      cancelled: Map.get(stats, "cancelled", 0),
      refunded: Map.get(stats, "refunded", 0)
    }
  end

  @doc """
  Returns ticket statistics for a specific event.

  ## Examples

      iex> get_event_ticket_stats(event_id)
      %{total: 100, active: 80, used: 15, cancelled: 5}

  """
  def get_event_ticket_stats(event_id) do
    stats =
      Ticket
      |> join(:inner, [t], tt in assoc(t, :ticket_type))
      |> where([t, tt], tt.event_id == ^event_id)
      |> group_by([t], t.status)
      |> select([t], {t.status, count(t.id)})
      |> Repo.all()
      |> Enum.into(%{})

    %{
      total: Enum.sum(Map.values(stats)),
      active: Map.get(stats, "active", 0),
      used: Map.get(stats, "used", 0),
      cancelled: Map.get(stats, "cancelled", 0),
      refunded: Map.get(stats, "refunded", 0)
    }
  end
end
