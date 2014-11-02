defmodule Blog.Repo.Migrations.AddPostsTable do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE posts (
      id         serial PRIMARY KEY,
      title      text,
      body       text,
      posted_at  timestamp,
      created_at timestamp,
      updated_at timestamp
    )
    """
  end

  def down do
    "DROP TABLE IF EXISTS posts"
  end
end
