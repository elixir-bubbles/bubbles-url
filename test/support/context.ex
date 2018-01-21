defmodule Url.Test.Context do
  def get_article_by_uri!(uri) do
    Url.Schema.get_by_uri!(uri, Url.Test.Repo, Url.Test.Url, Url.Test.Article)
  end

  def create_article(%{uri: uri} = attrs) do
    with {:ok, %{schema: article, url: url}} <-
           create_article_with_url(uri, fn url ->
             attrs = Map.put(attrs, :url_id, url.id)

             %Url.Test.Article{}
             |> Url.Test.Article.changeset(attrs)
             |> Url.Test.Repo.insert()
           end) do
      {:ok, Map.put(article, :url, url)}
    else
      error -> error
    end
  end

  defp create_article_with_url(uri, schema_create_fn) do
    Url.Schema.create_with_url(uri, Url.Test.Repo, Url.Test.Url, schema_create_fn)
  end

  def update_article(%Url.Test.Article{} = article, %{uri: uri} = attrs) do
    with {:ok, %{schema: article, url: url}} <-
           update_article_with_url(article, uri, fn url ->
             attrs = Map.put(attrs, :url_id, url.id)

             article
             |> Url.Test.Article.changeset(attrs)
             |> Url.Test.Repo.update()
           end) do
      {:ok, Map.put(article, :url, url)}
    else
      error -> error
    end
  end

  defp update_article_with_url(article, uri, schema_update_fn) do
    Url.Schema.update_with_url(article, uri, Url.Test.Repo, Url.Test.Url, schema_update_fn)
  end

  def delete_article(%Url.Test.Article{} = article) do
    Url.Schema.delete_with_url(article, Url.Test.Repo, Url.Test.Url, fn ->
      Url.Test.Repo.delete(article)
    end)
  end
end
