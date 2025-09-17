defmodule Ticketify.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(active inactive suspended)

  schema "tenants" do
    field :name, :string
    field :subdomain, :string
    field :description, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :logo_url, :string
    field :status, :string, default: "active"
    field :settings, :map, default: %{}

    # Relationships
    has_many :users, Ticketify.Users.User
    has_many :customers, Ticketify.Customers.Customer
    has_many :events, Ticketify.Events.Event

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name, :subdomain, :description, :email, :phone, :address, :logo_url, :status, :settings])
    |> validate_required([:name, :subdomain, :description, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_format(:subdomain, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$/, message: "must contain only lowercase letters, numbers, and hyphens")
    |> validate_length(:subdomain, min: 3, max: 30)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint(:subdomain)
    |> unique_constraint(:email)
  end

  @doc """
  Changeset for creating a new tenant
  """
  def create_changeset(tenant, attrs) do
    tenant
    |> changeset(attrs)
    |> put_change(:status, "active")
    |> put_change(:settings, default_settings())
  end

  @doc """
  Changeset for updating tenant status
  """
  def status_changeset(tenant, status) when status in @statuses do
    change(tenant, status: status)
  end

  defp default_settings do
    %{
      "timezone" => "UTC",
      "currency" => "USD",
      "email_notifications" => true,
      "sms_notifications" => false,
      "branding" => %{
        "primary_color" => "#3B82F6",
        "secondary_color" => "#1F2937"
      }
    }
  end

  @doc """
  Checks if tenant is active
  """
  def active?(%__MODULE__{status: "active"}), do: true
  def active?(_), do: false

  @doc """
  Returns tenant's full domain
  """
  def full_domain(%__MODULE__{subdomain: subdomain}) do
    "#{subdomain}.ticketify.com"
  end

  @doc """
  Gets a setting value with default fallback
  """
  def get_setting(%__MODULE__{settings: settings}, key, default \\ nil) do
    get_in(settings, String.split(key, ".")) || default
  end
end
