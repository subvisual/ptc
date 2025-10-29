defmodule Ptc.Repo do
  use Ecto.Repo,
    otp_app: :ptc,
    adapter: Ecto.Adapters.Postgres
end
