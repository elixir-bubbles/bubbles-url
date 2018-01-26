defmodule Bubbles.Url.GeneratorStrategy do
  @moduledoc """
  Implementes the `Bubbles.Url.GeneratorStrategyBehaviour` behaviour with
  default logic for generating unique URI strings among database records.
  """
  @behaviour Bubbles.Url.GeneratorStrategyBehaviour

  @doc """
  Generates a unique URI string among database records based on provided URI
  string.

  The default logic appends a numeric suffix to the URI, making sure the
  combination of URI and sufix is unique. For example, if `foo/bar-baz` is
  provided as first parameter, and there already is `foo/bar-baz` and
  `foo/bar-baz-1` in the database, the default logic will generate
  `foo/bar-baz-2`.
  """
  def generate_unique_uri(uri, repo, url_schema) do
    [uri, suffix] =
      case Regex.run(~r/(.+)\-(\d+)$/, uri, capture: :all_but_first) do
        [uri, suffix] -> [uri, String.to_integer(suffix)]
        nil -> [uri, 1]
      end

    unique_uri(uri, suffix, repo, url_schema)
  end

  defp unique_uri(uri, suffix, repo, url_schema) do
    new_uri = "#{uri}-#{suffix}"
    case repo.get_by(url_schema, uri: new_uri) do
      nil -> new_uri
      %url_schema{} -> unique_uri(uri, suffix + 1, repo, url_schema)
    end
  end
end
