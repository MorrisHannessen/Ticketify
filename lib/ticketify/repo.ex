defmodule Ticketify.Repo do
  use Ecto.Repo,
    otp_app: :ticketify,
    adapter: Ecto.Adapters.SQLite3
end
