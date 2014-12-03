defmodule Blog.Api.V3.Comments do
  use Relax.Resource, except: [:create, :update, :delete]
  alias Blog.Models.Comment

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V2.Comment
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    okay(conn, Comment.all)
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
