defmodule Blog.Api.V2.Posts do
  use Plug.Router
  use Relax.Responders
  use Relax.Params

  plug Plug.Parsers, parsers: [Relax.PlugParser]
  plug :match
  plug :dispatch
  alias Blog.Models.Post

  serializer Blog.Serializers.V2.Post
  error_serializer Blog.Serializers.V1.Error

  get "/" do
    okay(conn, Post.all)
  end

  get ":id" do
    case Post.find(id) do
      nil  -> not_found(conn)
      post -> okay(conn, post)
    end
  end
end
