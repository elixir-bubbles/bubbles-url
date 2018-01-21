defmodule Url.Schema do
  alias Ecto.Multi

  @default_strategy Url.GeneratorStrategy

  def get_by_uri!(uri, repo, url_schema_module, schema_module) do
    # TODO Rewrite into a single query using ecto query?
    url =
      url_schema_module
      |> repo.get_by!(uri: uri)
      |> get_final_url(repo, url_schema_module)

    repo.get_by!(schema_module, url_id: url.id)
    |> Map.put(:url, url)
  end

  defp get_final_url(url, repo, url_schema_module) do
    case url.redirects_to_url_id do
      nil ->
        url

      id ->
        url_schema_module
        |> repo.get(id)
        |> get_final_url(repo, url_schema_module)
    end
  end

  def create_with_url(uri, repo, url_schema, schema_create_fn, strategy \\ @default_strategy) do
    create_with_url_multi(uri, repo, url_schema, schema_create_fn, strategy)
    |> repo.transaction()
  end

  def create_with_url_multi(
        uri,
        repo,
        url_schema,
        schema_create_fn,
        strategy \\ @default_strategy
      ) do
    Multi.new()
    |> Multi.run(:url, fn _ -> Url.Generator.generate(uri, repo, url_schema, strategy) end)
    |> Multi.run(:schema, fn %{url: url} -> schema_create_fn.(url) end)
  end

  def update_with_url(
        schema,
        uri,
        repo,
        url_schema,
        schema_update_fn,
        strategy \\ @default_strategy
      ) do
    update_with_url_multi(schema, uri, repo, url_schema, schema_update_fn, strategy)
    |> repo.transaction()
  end

  def update_with_url_multi(
        schema,
        uri,
        repo,
        url_schema,
        schema_update_fn,
        strategy \\ @default_strategy
      ) do
    Multi.new()
    |> Multi.run(:url, fn _ ->
      Url.Generator.generate(uri, repo, url_schema, strategy, schema.url_id)
    end)
    |> Multi.run(:schema, fn %{url: url} -> schema_update_fn.(url) end)
  end

  def delete_with_url(schema, repo, url_schema, schema_delete_fn) do
    delete_with_url_multi(schema, repo, url_schema, schema_delete_fn)
    |> repo.transaction()
  end

  def delete_with_url_multi(schema, repo, url_schema, schema_delete_fn) do
    schema = repo.preload(schema, :url)

    Multi.new()
    |> Multi.run(:schema, fn _ -> schema_delete_fn.() end)
    |> delete_urls_multi(repo, url_schema, schema.url)
  end

  defp delete_urls_multi(multi, repo, url_schema, url) do
    # TODO Refactor using Ecto query and a single multi delete query?
    redirected_to_by = repo.get_by(url_schema, redirects_to_url_id: url.id)

    if redirected_to_by do
      multi = delete_urls_multi(multi, repo, url_schema, redirected_to_by)
    end

    multi
    |> Multi.delete(String.to_atom("delete_url_#{url.id}"), url)
  end
end
