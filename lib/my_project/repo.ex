defmodule MyProject.Repo do
  use Ecto.Repo,
    otp_app: :my_project,
    adapter: Ecto.Adapters.Postgres
end
