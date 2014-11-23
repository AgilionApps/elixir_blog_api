defmodule Blog.Api.V3.Comments do
  use JsonApi.Resource
  alias Blog.Models.Comment

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V2.Comment
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    case conn.params["posts"] do
      nil     -> okay(conn, Comment.all)
      post_id -> okay(conn, Comment.for_post(post_id))
    end
  end

  def find_many(conn, ids) do
    okay(conn, Comment.find(ids))
  end

  def find_one(conn, id) do
    case Comment.find(id) do
      nil     -> not_found(conn)
      comment -> okay(conn, comment)
    end
  end
end
