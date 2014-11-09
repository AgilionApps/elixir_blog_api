defmodule Blog.Api.V1.Posts do
  use JsonApi.Router
  alias Blog.Models.Post

  serializer Blog.Serializers.V1.Post

  get "/" do
    okay(conn, Post.all)
  end

  get ":id" do
    case Post.find(String.to_integer(id)) do
      nil  -> not_found(conn)
      post -> okay(conn, post)
    end
  end

  match _ do
    not_found(conn)
  end
end
