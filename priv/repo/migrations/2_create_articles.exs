defmodule TestRepo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add(:title, :string)
      add(:intro, :text)
      add(:url_id, references(:urls, on_delete: :nothing))

      timestamps()
    end

    create(index(:articles, [:url_id]))
  end
end
