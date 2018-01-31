defmodule Bubbles.Url.Test.Url do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field(:uri, :string)
    belongs_to(:url, Bubbles.Url.Test.Url, foreign_key: :redirects_to_url_id)
    timestamps()
  end

  @doc false
  def changeset(%Bubbles.Url.Test.Url{} = url, attrs) do
    url
    |> cast(attrs, [:uri, :redirects_to_url_id])
    |> validate_required([:uri])
  end
end
