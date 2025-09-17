defmodule Ticketify.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Customers.Customer
  alias Ticketify.Events
  alias Ticketify.Orders.Order
  alias Ticketify.Tenants.Tenant
  alias Ticketify.Tickets.Ticket

  @doc """
  Returns the list of orders for a tenant.

  ## Examples

      iex> list_orders(tenant)
      [%Order{}, ...]

  """
  def list_orders(%Tenant{} = tenant) do
    Order
    |> join(:inner, [o], c in assoc(o, :customer))
    |> where([o, c], c.tenant_id == ^tenant.id)
    |> order_by([o], desc: o.inserted_at)
    |> preload([:customer, :tickets])
    |> Repo.all()
  end

  @doc """
  Returns the list of orders for a customer.

  ## Examples

      iex> list_customer_orders(customer)
      [%Order{}, ...]

  """
  def list_customer_orders(%Customer{} = customer) do
    Order
    |> where([o], o.customer_id == ^customer.id)
    |> order_by([o], desc: o.inserted_at)
    |> preload(:tickets)
    |> Repo.all()
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Gets an order with tickets preloaded.

  ## Examples

      iex> get_order_with_tickets!(123)
      %Order{tickets: [%Ticket{}, ...]}

  """
  def get_order_with_tickets!(id) do
    Order
    |> where([o], o.id == ^id)
    |> preload(tickets: [ticket_type: :event])
    |> Repo.one!()
  end

  @doc """
  Creates an order with tickets.

  ## Examples

      iex> create_order(%{customer_email: "user@example.com"}, [%{ticket_type_id: 1, quantity: 2}])
      {:ok, %Order{}}

      iex> create_order(%{customer_email: "invalid"}, [])
      {:error, %Ecto.Changeset{}}

  """
  def create_order(order_attrs, ticket_items) do
    Repo.transaction(fn ->
      # Calculate total amount and validate ticket availability
      {total_amount, ticket_types} =
        ticket_items
        |> Enum.reduce({Decimal.new(0), []}, fn %{
                                                  ticket_type_id: ticket_type_id,
                                                  quantity: quantity
                                                },
                                                {total, types} ->
          ticket_type = Events.get_ticket_type!(ticket_type_id)

          if ticket_type.available >= quantity do
            item_total = Decimal.mult(ticket_type.price, quantity)
            {Decimal.add(total, item_total), [{ticket_type, quantity} | types]}
          else
            Repo.rollback({:error, "Not enough tickets available for #{ticket_type.name}"})
          end
        end)

      # Create the order
      order_attrs = Map.put(order_attrs, :total_amount, total_amount)

      case %Order{}
           |> Order.create_changeset(order_attrs)
           |> Repo.insert() do
        {:ok, order} ->
          create_tickets_for_order(order, ticket_types)

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  # Private helper function to create tickets for an order
  defp create_tickets_for_order(order, ticket_types) do
    Enum.each(ticket_types, fn {ticket_type, quantity} ->
      case Events.reserve_tickets(ticket_type, quantity) do
        {:ok, _} ->
          create_individual_tickets(order, ticket_type, quantity)

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)

    order
  end

  # Private helper function to create individual ticket records
  defp create_individual_tickets(order, ticket_type, quantity) do
    for _ <- 1..quantity do
      %Ticket{}
      |> Ticket.create_changeset(%{})
      |> Ecto.Changeset.put_assoc(:order, order)
      |> Ecto.Changeset.put_assoc(:ticket_type, ticket_type)
      |> Repo.insert!()
    end
  end

  @doc """
  Updates an order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Confirms an order.

  ## Examples

      iex> confirm_order(order)
      {:ok, %Order{}}

  """
  def confirm_order(%Order{} = order) do
    order
    |> Order.confirm_changeset()
    |> Repo.update()
  end

  @doc """
  Marks an order as paid.

  ## Examples

      iex> pay_order(order)
      {:ok, %Order{}}

  """
  def pay_order(%Order{} = order) do
    order
    |> Order.paid_changeset()
    |> Repo.update()
  end

  @doc """
  Cancels an order and releases tickets.

  ## Examples

      iex> cancel_order(order)
      {:ok, %Order{}}

  """
  def cancel_order(%Order{} = order) do
    Repo.transaction(fn ->
      # Load tickets with ticket types
      order = Repo.preload(order, tickets: :ticket_type)

      # Release tickets back to availability
      order.tickets
      |> Enum.group_by(& &1.ticket_type_id)
      |> Enum.each(fn {_ticket_type_id, tickets} ->
        ticket_type = hd(tickets).ticket_type
        count = length(tickets)
        Events.release_tickets(ticket_type, count)
      end)

      # Cancel all tickets
      order.tickets
      |> Enum.each(fn ticket ->
        ticket
        |> Ticket.cancel_changeset()
        |> Repo.update!()
      end)

      # Cancel the order
      order
      |> Order.cancel_changeset()
      |> Repo.update!()
    end)
  end

  @doc """
  Deletes an order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
