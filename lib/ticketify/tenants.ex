defmodule Ticketify.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Tenants.Tenant

  @doc """
  Returns the list of tenants.

  ## Examples

      iex> list_tenants()
      [%Tenant{}, ...]

  """
  def list_tenants do
    Repo.all(Tenant)
  end

  @doc """
  Returns the list of active tenants.

  ## Examples

      iex> list_active_tenants()
      [%Tenant{}, ...]

  """
  def list_active_tenants do
    Tenant
    |> where([t], t.status == "active")
    |> order_by([t], asc: t.name)
    |> Repo.all()
  end

  @doc """
  Gets a single tenant.

  Raises `Ecto.NoResultsError` if the Tenant does not exist.

  ## Examples

      iex> get_tenant!(123)
      %Tenant{}

      iex> get_tenant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tenant!(id), do: Repo.get!(Tenant, id)

  @doc """
  Gets a tenant by subdomain.

  ## Examples

      iex> get_tenant_by_subdomain("summer-fest")
      %Tenant{}

      iex> get_tenant_by_subdomain("nonexistent")
      nil

  """
  def get_tenant_by_subdomain(subdomain) do
    Repo.get_by(Tenant, subdomain: subdomain)
  end

  @doc """
  Creates a tenant.

  ## Examples

      iex> create_tenant(%{field: value})
      {:ok, %Tenant{}}

      iex> create_tenant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tenant(attrs \\ %{}) do
    %Tenant{}
    |> Tenant.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tenant.

  ## Examples

      iex> update_tenant(tenant, %{field: new_value})
      {:ok, %Tenant{}}

      iex> update_tenant(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tenant(%Tenant{} = tenant, attrs) do
    tenant
    |> Tenant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a tenant's status.

  ## Examples

      iex> update_tenant_status(tenant, "suspended")
      {:ok, %Tenant{}}

  """
  def update_tenant_status(%Tenant{} = tenant, status) do
    tenant
    |> Tenant.status_changeset(status)
    |> Repo.update()
  end

  @doc """
  Deletes a tenant.

  ## Examples

      iex> delete_tenant(tenant)
      {:ok, %Tenant{}}

      iex> delete_tenant(tenant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tenant(%Tenant{} = tenant) do
    Repo.delete(tenant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant changes.

  ## Examples

      iex> change_tenant(tenant)
      %Ecto.Changeset{data: %Tenant{}}

  """
  def change_tenant(%Tenant{} = tenant, attrs \\ %{}) do
    Tenant.changeset(tenant, attrs)
  end

  @doc """
  Updates tenant settings.

  ## Examples

      iex> update_tenant_settings(tenant, %{"timezone" => "EST"})
      {:ok, %Tenant{}}

  """
  def update_tenant_settings(%Tenant{} = tenant, new_settings) do
    settings = Map.merge(tenant.settings || %{}, new_settings)
    update_tenant(tenant, %{settings: settings})
  end

  @doc """
  Gets tenant statistics.

  ## Examples

      iex> get_tenant_stats(tenant)
      %{users: 5, events: 10, customers: 150, orders: 75}

  """
  def get_tenant_stats(%Tenant{} = tenant) do
    tenant = Repo.preload(tenant, [:users, :events, :customers])

    %{
      users: length(tenant.users),
      events: length(tenant.events),
      customers: length(tenant.customers),
      orders: get_tenant_order_count(tenant.id)
    }
  end

  defp get_tenant_order_count(tenant_id) do
    from(o in Ticketify.Orders.Order,
      join: c in assoc(o, :customer),
      where: c.tenant_id == ^tenant_id,
      select: count(o.id)
    )
    |> Repo.one()
  end
end
