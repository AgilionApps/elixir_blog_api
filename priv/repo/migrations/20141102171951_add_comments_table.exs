defmodule Blog.Repo.Migrations.AddCommentsTable do
  use Ecto.Migration

  def up do
    [
      """
        CREATE TABLE comments (
          id         serial PRIMARY KEY,
          body       text,
          post_id    integer,
          created_at timestamp,
          updated_at timestamp
        )
      """,
      "CREATE INDEX ON comments (post_id)"
    ]
  end

  def down do
    "DROP TABLE IF EXISTS comments"
  end
end
