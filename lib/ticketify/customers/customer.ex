defmodule Ticketify.Customers.Customer do
  @moduledoc """
  Customer schema representing ticket buyers.

  Customers are scoped to tenants and represent the people who
  purchase tickets for events.
  """
  use Ecto.Schema
  use Ticketify.TrackedObject
  import Ecto.Changeset

  schema "customers" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :date_of_birth, :date
    field :preferences, :map, default: %{}

    # Relationships
    belongs_to :tenant, Ticketify.Tenants.Tenant
    has_many :orders, Ticketify.Orders.Order

    # Tracked object fields (created_at, updated_at, deleted_at)
    tracked_timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email, :first_name, :last_name, :phone, :date_of_birth, :preferences])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> validate_age()
    |> unique_constraint([:email, :tenant_id], name: :customers_email_tenant_id_index)
    |> foreign_key_constraint(:tenant_id)
  end

  defp validate_age(changeset) do
    case get_field(changeset, :date_of_birth) do
      nil ->
        changeset

      date_of_birth ->
        age = Date.diff(Date.utc_today(), date_of_birth) / 365.25

        if age >= 13 do
          changeset
        else
          add_error(changeset, :date_of_birth, "must be at least 13 years old")
        end
    end
  end

  @doc """
  Returns customer's full name
  """
  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  @doc """
  Returns customer's age
  """
  def age(%__MODULE__{date_of_birth: nil}), do: nil

  def age(%__MODULE__{date_of_birth: date_of_birth}) do
    trunc(Date.diff(Date.utc_today(), date_of_birth) / 365.25)
  end

  @doc """
  Gets a preference value with default fallback
  """
  def get_preference(%__MODULE__{preferences: preferences}, key, default \\ nil) do
    get_in(preferences, String.split(key, ".")) || default
  end

  @doc """
  Updates customer preferences
  """
  def update_preferences(customer, new_preferences) do
    preferences = Map.merge(customer.preferences || %{}, new_preferences)
    change(customer, preferences: preferences)
  end
end
