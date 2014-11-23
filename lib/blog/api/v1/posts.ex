defmodule Blog.Api.V1.Posts do
  use JsonApi.Resource
  alias Blog.Models.Post

  plug :match
  plug :dispatch

  serializer Blog.Serializers.V1.Post
  error_serializer Blog.Serializers.V1.Error

  def find_all(conn) do
    okay(conn, Post.all)
  end

  def find_many(conn, ids) do
    okay(conn, Post.find(ids))
  end

  def find_one(conn, id) do
    case Post.find(id) do
      nil     -> not_found(conn)
      comment -> okay(conn, comment)
    end
  end

  post "/" do
    filter_params(conn, {"posts", [:title, :body]}) do
      case Post.create(params) do
        {:ok,    post}   -> created(conn, post)
        {:error, errors} -> invalid(conn, errors)
      end
    end
  end

  match _ do
    not_found(conn)
  end
end
