defmodule Bubbles.Url.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bubbles.Url.Test.Repo)
  end
end

Bubbles.Url.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Bubbles.Url.Test.Repo, :manual)

ExUnit.start()
