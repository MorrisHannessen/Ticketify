defmodule Ticketify.Orders.Order do
  @moduledoc """
  Order schema representing ticket purchase transactions.

  Orders contain customer information and are associated with
  multiple tickets for a specific event.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending confirmed paid cancelled refunded)

  schema "orders" do
    field :total_amount, :decimal
    field :status, :string, default: "pending"
    field :customer_email, :string
    field :customer_first_name, :string
    field :customer_last_name, :string
    field :customer_phone, :string

    # Relationships
    belongs_to :customer, Ticketify.Customers.Customer
    has_many :tickets, Ticketify.Tickets.Ticket, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :total_amount,
      :status,
      :customer_email,
      :customer_first_name,
      :customer_last_name,
      :customer_phone
    ])
    |> validate_required([
      :total_amount,
      :customer_email,
      :customer_first_name,
      :customer_last_name
    ])
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:total_amount, greater_than: 0)
    |> validate_format(:customer_email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:customer_first_name, min: 2, max: 50)
    |> validate_length(:customer_last_name, min: 2, max: 50)
  end

  @doc """
  Changeset for creating a new order
  """
  def create_changeset(order, attrs) do
    order
    |> changeset(attrs)
    |> put_change(:status, "pending")
  end

  @doc """
  Changeset for confirming an order
  """
  def confirm_changeset(order) do
    change(order, status: "confirmed")
  end

  @doc """
  Changeset for marking order as paid
  """
  def paid_changeset(order) do
    change(order, status: "paid")
  end

  @doc """
  Changeset for cancelling an order
  """
  def cancel_changeset(order) do
    change(order, status: "cancelled")
  end

  @doc """
  Returns customer's full name
  """
  def customer_full_name(%__MODULE__{
        customer_first_name: first_name,
        customer_last_name: last_name
      }) do
    "#{first_name} #{last_name}"
  end

  @doc """
  Checks if order can be cancelled
  """
  def cancellable?(%__MODULE__{status: status}) when status in ~w(pending confirmed), do: true
  def cancellable?(_), do: false

  @doc """
  Checks if order is completed (paid)
  """
  def completed?(%__MODULE__{status: "paid"}), do: true
  def completed?(_), do: false

  @doc """
  Generates order number from ID
  """
  def order_number(%__MODULE__{id: id}) when is_integer(id) do
    "TIX-#{String.pad_leading(Integer.to_string(id), 6, "0")}"
  end

  def order_number(_), do: nil
end
