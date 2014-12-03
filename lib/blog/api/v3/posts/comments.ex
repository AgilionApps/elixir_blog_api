defmodule Blog.Api.V3.Post.Comments do
  use Relax.Resource, only: [:find_all]
  alias Blog.Models.Comment

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V2.Comment
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    okay(conn, Comment.for_post(conn.params["posts"]))
  end
end
