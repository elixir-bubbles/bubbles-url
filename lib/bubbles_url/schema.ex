defmodule Bubbles.Url.Schema do
  @moduledoc """
  Provides a set of functions for creating, updating and deleting schemas which
  have associated URLs.

  For example, if we have a `Foo.Article` schema and in our domain each article has
  an associated URL, represented by the `Foo.Url` schema, then `Foo.Article` is
  the schema this module is intended to work with. If a function expects to
  receive a `schema_module` parameter, it expects `Foo.Article` to be passed to
  it. If a function expects to receive a `schema` parameter, it expects an
  actual `%Foo.Article{}` struct.

  `Bubbles.Url.Schema` is meant to be used where schemas are being updated. If
  we're working with Phoenix and our domain is organized into contexts, we'd
  modify the context methods for creating, updating and deleting schemas. Also,
  for brefity, we can wrap `Bubbles.Url.Schema` functions in helper functions.
  See the following example of a modified context:

      alias Foo.{Article, Url, Repo}

      def create_article(%{uri: uri} = attrs) do
        with {:ok, %{schema: article, url: url}} <-
               create_article_with_url(uri, fn url ->
                 attrs = Map.put(attrs, :url_id, url.id)

                 %Article{}
                 |> Article.changeset(attrs)
                 |> Repo.insert()
               end) do
          {:ok, Map.put(article, :url, url)}
        else
          error -> error
        end
      end

      defp create_article_with_url(uri, schema_create_fn) do
        Schema.create_with_url(uri, Repo, Url, schema_create_fn)
      end
  """
  alias Ecto.Multi

  @default_strategy Bubbles.Url.GeneratorStrategy

  @doc """
  Fetches a struct of `schema_module` type associated with the URL that has the
  matching `uri` attribute.

  For brevity, this function can be wrapped in a function with a shorter
  signature, for example:

      get_article_by_uri!(uri) do
        Bubbles.Url.Schema.get_by_uri!(uri, Foo.Repo, Foo.Url, Foo.Article)
      end
  """
  def get_by_uri!(uri, repo, url_schema_module, schema_module) do
    url =
      url_schema_module
      |> repo.get_by!(uri: uri)
      |> get_final_url(repo, url_schema_module)

    schema = repo.get_by!(schema_module, url_id: url.id)
    Map.put(schema, :url, url)
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

  @doc """
  Creates a schema record including an associated Url record.

  The function expects a `schema_create_fn` function which receives a single
  parameter, the `Url` struct, and is expected to return a struct of created
  schema record.

  For example, if we have a Foo.Article and Foo.Url structs and each article has
  a URL, we'd call the function as:

      Bubbles.Url.Schema.create_with_url(uri, Foo.Repo, Foo.Url, fn url ->
        attrs = Map.put(attrs, :url_id, url.id)

        %Foo.Article{}
        |> Foo.Article.changeset(attrs)
        |> Foo.Repo.insert()
      end)
  """
  def create_with_url(uri, repo, url_schema, schema_create_fn, strategy \\ @default_strategy) do
    multi = create_with_url_multi(uri, repo, url_schema, schema_create_fn, strategy)
    repo.transaction(multi)
  end

  @doc """
  Creates an `Ecto.Multi` struct for creating a schema record including an
  associated Url record.

  This function is used in `create_with_url/5` and immediately executed in a
  transaction. On its own, it can be easily used as part of a larger
  `Ecto.Multi` operations pipeline.
  """
  def create_with_url_multi(
        uri,
        repo,
        url_schema,
        schema_create_fn,
        strategy \\ @default_strategy
      ) do
    Multi.new()
    |> Multi.run(:url, fn _ -> Bubbles.Url.Generator.generate(uri, repo, url_schema, strategy) end)
    |> Multi.run(:schema, fn %{url: url} -> schema_create_fn.(url) end)
  end

  @doc """
  Updates a schema record including updating the associated Url record
  if provided uri has changed.

  The function expects a `schema_update_fn` function which receives a single
  parameter, the `Url` struct, and is expected to return a struct of updated
  schema record.

  For example, if we have a Foo.Article and Foo.Url structs and each article has
  a URL, we'd call the function as:

      Bubbles.Url.Schema.update_with_url(uri, Foo.Repo, Foo.Url, fn url ->
        attrs = Map.put(attrs, :url_id, url.id)

        %Foo.Article{}
        |> Foo.Article.changeset(attrs)
        |> Foo.Repo.update()
      end)
  """
  def update_with_url(
        schema,
        uri,
        repo,
        url_schema,
        schema_update_fn,
        strategy \\ @default_strategy
      ) do
    multi = update_with_url_multi(schema, uri, repo, url_schema, schema_update_fn, strategy)
    repo.transaction(multi)
  end

  @doc """
  Creates an `Ecto.Multi` struct for updating a schema record including updating
  an associated Url record.

  This function is used in `update_with_url/5` and immediately executed in a
  transaction. On its own, it can be easily used as part of a larger
  `Ecto.Multi` operations pipeline.
  """
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
      Bubbles.Url.Generator.generate(uri, repo, url_schema, strategy, schema.url_id)
    end)
    |> Multi.run(:schema, fn %{url: url} -> schema_update_fn.(url) end)
  end

  @doc """
  Deleted a schema record including deleting the associated Url record(s).

  The function expects a `schema_delete_fn` function which is expected to delete
  the schema record.

  For example, if we have a Foo.Article and Foo.Url structs and each article has
  a URL, we'd call the function as:

      Bubbles.Url.Schema.delete_with_url(article, Foo.Repo, Foo.Url, fn ->
        Foo.Repo.delete(article)
      end)
  """
  def delete_with_url(schema, repo, url_schema, schema_delete_fn) do
    multi = delete_with_url_multi(schema, repo, url_schema, schema_delete_fn)
    repo.transaction(multi)
  end

  @doc """
  Creates an `Ecto.Multi` struct for deleting a schema record including deleting
  the associated Url record.

  This function is used in `delete_with_url/4` and immediately executed in a
  transaction. On its own, it can be easily used as part of a larger
  `Ecto.Multi` operations pipeline.
  """
  def delete_with_url_multi(schema, repo, url_schema, schema_delete_fn) do
    schema = repo.preload(schema, :url)

    Multi.new()
    |> Multi.run(:schema, fn _ -> schema_delete_fn.() end)
    |> delete_urls_multi(repo, url_schema, schema.url)
  end

  defp delete_urls_multi(multi, repo, url_schema, url) do
    redirected_to_by = repo.get_by(url_schema, redirects_to_url_id: url.id)

    multi =
      case redirected_to_by do
        %url_schema{} ->
          delete_urls_multi(multi, repo, url_schema, redirected_to_by)

        nil ->
          multi
      end

    Multi.delete(multi, String.to_atom("delete_url_#{url.id}"), url)
  end
end
