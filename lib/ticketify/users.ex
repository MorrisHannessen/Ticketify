defmodule Ticketify.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Ticketify.Repo

  alias Ticketify.Users.User
  alias Ticketify.Tenants.Tenant

  @doc """
  Returns the list of users for a tenant.

  ## Examples

      iex> list_users(tenant)
      [%User{}, ...]

  """
  def list_users(%Tenant{} = tenant) do
    User
    |> where([u], u.tenant_id == ^tenant.id)
    |> order_by([u], asc: u.first_name, asc: u.last_name)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by email within a tenant.

  ## Examples

      iex> get_user_by_email(tenant, "user@example.com")
      %User{}

      iex> get_user_by_email(tenant, "nonexistent@example.com")
      nil

  """
  def get_user_by_email(%Tenant{} = tenant, email) do
    User
    |> where([u], u.tenant_id == ^tenant.id and u.email == ^email)
    |> Repo.one()
  end

  @doc """
  Creates a user for a tenant.

  ## Examples

      iex> create_user(tenant, %{field: value})
      {:ok, %User{}}

      iex> create_user(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(%Tenant{} = tenant, attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tenant, tenant)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Confirms a user's email.

  ## Examples

      iex> confirm_user(user)
      {:ok, %User{}}

  """
  def confirm_user(%User{} = user) do
    user
    |> User.confirm_changeset()
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Authenticates a user by email and password within a tenant.

  ## Examples

      iex> authenticate_user(tenant, "user@example.com", "password")
      {:ok, %User{}}

      iex> authenticate_user(tenant, "user@example.com", "wrong_password")
      {:error, :invalid_credentials}

  """
  def authenticate_user(%Tenant{} = tenant, email, password) do
    user = get_user_by_email(tenant, email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      true ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
