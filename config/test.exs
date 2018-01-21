use Mix.Config

config :url, ecto_repos: [Url.Test.Repo]

config :url, Url.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "bubbles",
  password: "bubbles",
  database: "example_test",
  hostname: "postgres"

config :logger, :console, level: :error
