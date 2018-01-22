defmodule TestRepo.Migrations.CreateUrl do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add(:uri, :string)
      add(:redirects_to_url_id, references(:urls, on_delete: :nothing))

      timestamps()
    end

    create(index(:urls, [:redirects_to_url_id]))
  end
end
