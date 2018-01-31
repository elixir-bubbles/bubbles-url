defmodule Bubbles.Url.Test.Article do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field(:title, :string)
    belongs_to(:url, Bubbles.Url.Test.Url)
    timestamps()
  end

  @doc false
  def changeset(%Bubbles.Url.Test.Article{} = article, attrs) do
    article
    |> cast(attrs, [:title, :url_id])
    |> assoc_constraint(:url)
    |> validate_required([:title])
  end
end
