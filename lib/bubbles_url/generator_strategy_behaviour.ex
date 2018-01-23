defmodule Bubbles.Url.GeneratorStrategyBehaviour do
  @moduledoc """
  In case a custom strategy for generating unique URIs needs to be implemented
  this behaviour should be implemented by the module responsible for the custom
  strategy.
  """

  @doc """
  Generates a URI string which is unique among existing URL records in the
  database.

  It takes the URI string as parameter and returns either that same
  string if it already is unique, or a modified string. See examples in
  documentation for default `Bubbles.Url.GeneratorStrategy` module.
  """
  @callback generate_unique_uri(
              uri :: String.t(),
              repo :: Ecto.Repo.t(),
              url_schema :: Ecto.Schema.t()
            ) :: String.t()
end
