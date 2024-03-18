defmodule Zrl.Repo do
  use Ecto.Repo,
    otp_app: :zrl,
    # adapter: Ecto.Adapters.Postgres
    adapter: Ecto.Adapters.Tds

    use Scrivener
end
