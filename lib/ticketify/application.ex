defmodule Ticketify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicketifyWeb.Telemetry,
      Ticketify.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:ticketify, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:ticketify, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ticketify.PubSub},
      # Start a worker by calling: Ticketify.Worker.start_link(arg)
      # {Ticketify.Worker, arg},
      # Start to serve requests, typically the last entry
      TicketifyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ticketify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicketifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # Run migrations only when running a release (RELEASE_NAME is set by mix release)
    # Skip migrations in dev/test where the dev.exs config handles it differently
    System.get_env("RELEASE_NAME") == nil
  end
end
