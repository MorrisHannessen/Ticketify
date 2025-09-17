defmodule Ticketify.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Events.{Event, TicketType}
  alias Ticketify.Tenants.Tenant

  @doc """
  Returns the list of events for a tenant.

  ## Examples

      iex> list_events(tenant)
      [%Event{}, ...]

  """
  def list_events(%Tenant{} = tenant) do
    Event
    |> where([e], e.tenant_id == ^tenant.id)
    |> order_by([e], desc: e.start_date)
    |> Repo.all()
  end

  @doc """
  Returns the list of published events for a tenant.

  ## Examples

      iex> list_published_events(tenant)
      [%Event{}, ...]

  """
  def list_published_events(%Tenant{} = tenant) do
    Event
    |> where([e], e.tenant_id == ^tenant.id and e.status in ["published", "active"])
    |> order_by([e], asc: e.start_date)
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets an event by slug within a tenant.

  ## Examples

      iex> get_event_by_slug(tenant, "summer-festival")
      %Event{}

      iex> get_event_by_slug(tenant, "nonexistent")
      nil

  """
  def get_event_by_slug(%Tenant{} = tenant, slug) do
    Event
    |> where([e], e.tenant_id == ^tenant.id and e.slug == ^slug)
    |> Repo.one()
  end

  @doc """
  Gets an event with ticket types preloaded.

  ## Examples

      iex> get_event_with_ticket_types!(123)
      %Event{ticket_types: [%TicketType{}, ...]}

  """
  def get_event_with_ticket_types!(id) do
    Event
    |> where([e], e.id == ^id)
    |> preload(:ticket_types)
    |> Repo.one!()
  end

  @doc """
  Creates an event for a tenant.

  ## Examples

      iex> create_event(tenant, %{field: value})
      {:ok, %Event{}}

      iex> create_event(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%Tenant{} = tenant, attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tenant, tenant)
    |> Repo.insert()
  end

  @doc """
  Updates an event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  # Ticket Types

  @doc """
  Returns the list of ticket types for an event.

  ## Examples

      iex> list_ticket_types(event_id)
      [%TicketType{}, ...]

  """
  def list_ticket_types(event_id) do
    TicketType
    |> where([tt], tt.event_id == ^event_id)
    |> order_by([tt], asc: tt.price)
    |> Repo.all()
  end

  @doc """
  Gets a single ticket type.

  Raises `Ecto.NoResultsError` if the TicketType does not exist.

  ## Examples

      iex> get_ticket_type!(123)
      %TicketType{}

      iex> get_ticket_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket_type!(id), do: Repo.get!(TicketType, id)

  @doc """
  Creates a ticket type.

  ## Examples

      iex> create_ticket_type(event, %{field: value})
      {:ok, %TicketType{}}

      iex> create_ticket_type(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket_type(%Event{} = event, attrs \\ %{}) do
    %TicketType{}
    |> TicketType.create_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:event, event)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket type.

  ## Examples

      iex> update_ticket_type(ticket_type, %{field: new_value})
      {:ok, %TicketType{}}

      iex> update_ticket_type(ticket_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket_type(%TicketType{} = ticket_type, attrs) do
    ticket_type
    |> TicketType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket type.

  ## Examples

      iex> delete_ticket_type(ticket_type)
      {:ok, %TicketType{}}

      iex> delete_ticket_type(ticket_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket_type(%TicketType{} = ticket_type) do
    Repo.delete(ticket_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket type changes.

  ## Examples

      iex> change_ticket_type(ticket_type)
      %Ecto.Changeset{data: %TicketType{}}

  """
  def change_ticket_type(%TicketType{} = ticket_type, attrs \\ %{}) do
    TicketType.changeset(ticket_type, attrs)
  end

  @doc """
  Reserves tickets for purchase.

  ## Examples

      iex> reserve_tickets(ticket_type, 2)
      {:ok, %TicketType{}}

      iex> reserve_tickets(ticket_type, 100)
      {:error, %Ecto.Changeset{}}

  """
  def reserve_tickets(%TicketType{} = ticket_type, count) do
    ticket_type
    |> TicketType.reserve_tickets(count)
    |> Repo.update()
  end

  @doc """
  Releases reserved tickets (for cancellations).

  ## Examples

      iex> release_tickets(ticket_type, 2)
      {:ok, %TicketType{}}

  """
  def release_tickets(%TicketType{} = ticket_type, count) do
    ticket_type
    |> TicketType.release_tickets(count)
    |> Repo.update()
  end
end
