defmodule Ticketify.Users.User do
  @moduledoc """
  User schema for tenant administrators and managers.

  Users are scoped to tenants and represent the people who manage
  events and ticket sales for a specific organization.
  """
  use Ecto.Schema
  use Ticketify.TrackedObject
  import Ecto.Changeset

  @roles ~w(admin manager)

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :role, :string, default: "admin"
    field :password_hash, :string
    field :confirmed_at, :naive_datetime

    # Relationships
    belongs_to :tenant, Ticketify.Tenants.Tenant

    # Tracked object fields (created_at, updated_at, deleted_at)
    tracked_timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :phone, :role])
    |> validate_required([:email, :first_name, :last_name, :role])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_inclusion(:role, @roles)
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> unique_constraint(:email)
  end

  @doc """
  Changeset for registration with password validation
  """
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 100)
    |> validate_format(:password, ~r/[A-Z]/,
      message: "must contain at least one uppercase letter"
    )
    |> validate_format(:password, ~r/[a-z]/,
      message: "must contain at least one lowercase letter"
    )
    |> validate_format(:password, ~r/[0-9]/, message: "must contain at least one number")
    |> hash_password()
  end

  @doc """
  Changeset for email confirmation
  """
  def confirm_changeset(user) do
    change(user, confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  Returns full name of the user
  """
  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  @doc """
  Checks if user is admin
  """
  def admin?(%__MODULE__{role: "admin"}), do: true
  def admin?(_), do: false
end
