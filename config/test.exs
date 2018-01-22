use Mix.Config

config :bubbles_url, ecto_repos: [Bubbles.Url.Test.Repo]

config :bubbles_url, Bubbles.Url.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: "example_test",
  hostname: System.get_env("DB_HOSTNAME")

config :logger, :console, level: :error
