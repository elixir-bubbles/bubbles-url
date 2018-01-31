defmodule Bubbles.Url.Test.Context do
  @moduledoc false

  alias Bubbles.Url.Schema
  alias Bubbles.Url.Test.{Article, Url, Repo}

  def get_article_by_uri!(uri) do
    Schema.get_by_uri!(uri, Repo, Url, Article)
  end

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

  def update_article(%Article{} = article, %{uri: uri} = attrs) do
    with {:ok, %{schema: article, url: url}} <-
           update_article_with_url(article, uri, fn url ->
             attrs = Map.put(attrs, :url_id, url.id)

             article
             |> Article.changeset(attrs)
             |> Repo.update()
           end) do
      {:ok, Map.put(article, :url, url)}
    else
      error -> error
    end
  end

  defp update_article_with_url(article, uri, schema_update_fn) do
    Schema.update_with_url(article, uri, Repo, Url, schema_update_fn)
  end

  def delete_article(%Article{} = article) do
    Schema.delete_with_url(article, Repo, Url, fn ->
      Repo.delete(article)
    end)
  end
end
