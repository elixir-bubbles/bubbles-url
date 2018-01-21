defmodule Url.Test.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field(:uri, :string)
    belongs_to(:url, Url.Test.Url, foreign_key: :redirects_to_url_id)
    timestamps()
  end

  @doc false
  def changeset(%Url.Test.Url{} = url, attrs) do
    url
    |> cast(attrs, [:uri, :redirects_to_url_id])
    |> validate_required([:uri])
  end
end
