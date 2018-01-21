defmodule UrlTest do
  use Url.TestCase
  # doctest Url

  test "fetches article by url" do
    create_article()
    article = Url.Test.Context.get_article_by_uri!("test-article-old-uri")

    assert article.url_id != nil
    assert article.title == "Test Article"
  end

  test "creates article with url" do
    {:ok, article} =
      Url.Test.Context.create_article(%{
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
      Url.Test.Context.update_article(article, %{
        title: "Updated Article Title",
        uri: "updated-test-uri"
      })

    assert article.title == "Updated Article Title"
    assert article.url.uri == "updated-test-uri"

    redirected_article = Url.Test.Context.get_article_by_uri!("test-article-old-uri")

    assert article.id == redirected_article.id
  end

  test "deletes article and url" do
    article = create_article()
    Url.Test.Context.delete_article(article)

    articles = Url.Test.Repo.all(Url.Test.Article)
    urls = Url.Test.Repo.all(Url.Test.Url)

    assert articles == []
    assert urls == []
  end

  defp create_article() do
    new_url =
      %Url.Test.Url{
        uri: "test-article"
      }
      |> Url.Test.Repo.insert!()

    old_url =
      %Url.Test.Url{
        uri: "test-article-old-uri",
        redirects_to_url_id: new_url.id
      }
      |> Url.Test.Repo.insert!()

    %Url.Test.Article{
      title: "Test Article",
      url_id: new_url.id
    }
    |> Url.Test.Repo.insert!()
  end
end
