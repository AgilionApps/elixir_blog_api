defmodule Blog.Api.V3.Posts do
  use JsonApi.Resource, only: [:find_all, :find_many, :find_one]
  alias Blog.Models.Post

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V3.Post
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    okay(conn, Post.all)
  end

  def find_many(conn, ids) do
    okay(conn, Post.find(ids))
  end

  def find_one(conn, id) do
    case Post.find(id) do
      nil  -> not_found(conn)
      post -> okay(conn, post)
    end
  end
end
