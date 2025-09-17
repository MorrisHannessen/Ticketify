defmodule Ticketify.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Customers.Customer
  alias Ticketify.Tenants.Tenant

  @doc """
  Returns the list of customers for a tenant.

  ## Examples

      iex> list_customers(tenant)
      [%Customer{}, ...]

  """
  def list_customers(%Tenant{} = tenant) do
    Customer
    |> where([c], c.tenant_id == ^tenant.id)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  @doc """
  Gets a customer by email within a tenant.

  ## Examples

      iex> get_customer_by_email(tenant, "customer@example.com")
      %Customer{}

      iex> get_customer_by_email(tenant, "nonexistent@example.com")
      nil

  """
  def get_customer_by_email(%Tenant{} = tenant, email) do
    Customer
    |> where([c], c.tenant_id == ^tenant.id and c.email == ^email)
    |> Repo.one()
  end

  @doc """
  Creates a customer for a tenant.

  ## Examples

      iex> create_customer(tenant, %{field: value})
      {:ok, %Customer{}}

      iex> create_customer(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(%Tenant{} = tenant, attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tenant, tenant)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates customer preferences.

  ## Examples

      iex> update_customer_preferences(customer, %{"newsletter" => true})
      {:ok, %Customer{}}

  """
  def update_customer_preferences(%Customer{} = customer, new_preferences) do
    customer
    |> Customer.update_preferences(new_preferences)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  @doc """
  Searches customers by name or email within a tenant.

  ## Examples

      iex> search_customers(tenant, "john")
      [%Customer{}, ...]

  """
  def search_customers(%Tenant{} = tenant, query) do
    search_term = "%#{query}%"

    Customer
    |> where([c], c.tenant_id == ^tenant.id)
    |> where([c],
      ilike(c.first_name, ^search_term) or
      ilike(c.last_name, ^search_term) or
      ilike(c.email, ^search_term)
    )
    |> order_by([c], asc: c.first_name, asc: c.last_name)
    |> limit(50)
    |> Repo.all()
  end

  @doc """
  Gets customer statistics for a tenant.

  ## Examples

      iex> get_customer_stats(tenant)
      %{total: 150, new_this_month: 25}

  """
  def get_customer_stats(%Tenant{} = tenant) do
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)

    total_query =
      Customer
      |> where([c], c.tenant_id == ^tenant.id)
      |> select([c], count(c.id))

    new_this_month_query =
      Customer
      |> where([c], c.tenant_id == ^tenant.id and c.inserted_at >= ^thirty_days_ago)
      |> select([c], count(c.id))

    %{
      total: Repo.one(total_query),
      new_this_month: Repo.one(new_this_month_query)
    }
  end

  @doc """
  Finds or creates a customer by email for a tenant.

  ## Examples

      iex> find_or_create_customer(tenant, %{email: "new@example.com", first_name: "John", last_name: "Doe"})
      {:ok, %Customer{}}

  """
  def find_or_create_customer(%Tenant{} = tenant, attrs) do
    case get_customer_by_email(tenant, attrs[:email] || attrs["email"]) do
      nil -> create_customer(tenant, attrs)
      customer -> {:ok, customer}
    end
  end
end
