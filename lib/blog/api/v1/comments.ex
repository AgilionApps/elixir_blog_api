defmodule Blog.Api.V1.Comments do
  use Relax.Resource, except: [:update, :delete]
  alias Blog.Models.Comment

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V1.Comment
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    okay(conn, Comment.all, %{page: 1, total_pages: 1})
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

  @post_params {"comments", [:body, {:post_id, "links.post"}]}

  def create(conn) do
    params = filter_params(conn, @post_params)
    case Comment.create(params) do
      {:ok,    comment} -> created(conn, comment)
      {:error, errors}  -> invalid(conn, errors)
    end
  end
end
