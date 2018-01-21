defmodule Url.GeneratorStrategy do
  @behaviour Url.GeneratorStrategyBehaviour

  @repo Application.get_env(:url, :repo)
  @url Application.get_env(:url, :schema)

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
    # TODO Find by LIKE uri, order by uri desc and take first?
    case repo.get_by(url_schema, uri: new_uri) do
      nil -> new_uri
      %url_schema{} -> unique_uri(uri, suffix + 1, repo, url_schema)
    end
  end
end
