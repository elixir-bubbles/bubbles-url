defmodule Bubbles.UrlTest do
  use Bubbles.Url.TestCase

  alias Bubbles.Url.Test.{Context, Article, Url, Repo}

  test "fetches article by url" do
    create_article()
    article = Context.get_article_by_uri!("test-article-old-uri")

    assert article.url_id != nil
    assert article.title == "Test Article"
  end

  test "creates article with url" do
    {:ok, article} =
      Context.create_article(%{
        uri: "some-test-uri",
        title: "Article Title"
      })

    assert article.url_id != nil
    assert article.title == "Article Title"
    assert article.url.uri == "some-test-uri"
  end

  test "updates article and url" do
    article = create_article()

    {:ok, article} =
      Context.update_article(article, %{
        title: "Updated Article Title",
        uri: "updated-test-uri"
      })

    assert article.title == "Updated Article Title"
    assert article.url.uri == "updated-test-uri"

    redirected_article = Context.get_article_by_uri!("test-article-old-uri")

    assert article.id == redirected_article.id
  end

  test "deletes article and url" do
    article = create_article()
    Context.delete_article(article)

    articles = Repo.all(Article)
    urls = Repo.all(Url)
    assert articles == []
    assert urls == []
  end

  defp create_article() do
    new_url =
      %Url{
        uri: "test-article"
      }
      |> Repo.insert!()

    %Url{
      uri: "test-article-old-uri",
      redirects_to_url_id: new_url.id
    }
    |> Repo.insert!()

    %Article{
      title: "Test Article",
      url_id: new_url.id
    }
    |> Repo.insert!()
  end
end
