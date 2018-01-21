defmodule Url.GeneratorStrategyBehaviour do
  @callback generate_unique_uri(uri :: String.t()) :: String.t()
end
