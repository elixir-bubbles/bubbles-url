defmodule Bubbles.Url.Generator do
  @moduledoc """
  Provides functions for generating URL records.
  """

  @doc """
  Generates and inserts a Url schema record with a unique URI if one already
  exists.

  A generator strategy module is provided as the fourth parameter which is used
  to provide the unique URI string if one already exists among database records.
  """
  def generate(uri, repo, url_schema, strategy) do
    if url = repo.get_by(url_schema, uri: uri) do
      uri = strategy.generate_unique_uri(uri, repo, url_schema)
    end

    url_schema
    |> struct()
    |> url_schema.changeset(%{uri: uri})
    |> repo.insert()
  end

  @doc """
  Generates and inserts a Url schema record with a unique URI only if the
  provided `uri` string is different from `uri` attribute of Url record with
  `id` value of primary key.
  """
  def generate(uri, repo, url_schema, strategy, id) do
    with url = %url_schema{} <- repo.get(url_schema, id) do
      case url.uri == uri do
        true ->
          url

        false ->
          {:ok, new_url} = generate(uri, repo, url_schema, strategy)

          res =
            url
            |> url_schema.changeset(%{redirects_to_url_id: new_url.id})
            |> repo.update()

          {:ok, new_url}
      end
    else
      error -> error
    end
  end
end
