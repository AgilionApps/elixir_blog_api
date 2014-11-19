defmodule Blog.Api.V1.Posts do
  use JsonApi.Resource
  alias Blog.Models.Post

  serializer Blog.Serializers.V1.Post
  error_serializer Blog.Serializers.V1.Error

  get "/" do
    okay(conn, Post.all)
  end

  get ":id" do
    case Post.find(String.to_integer(id)) do
      nil  -> not_found(conn)
      post -> okay(conn, post)
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
