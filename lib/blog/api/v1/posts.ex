defmodule Blog.Api.V1.Posts do
  import Plug.Conn
  use Plug.Router
  use JsonApi.Responders
  alias Blog.Models.Post

  @serializer Blog.Serializers.V1.Post

  plug :match
  plug :dispatch

  get "/" do
    send_json(conn, 200, Post.all)
  end

  get ":id" do
    case Post.find(String.to_integer(id)) do
      nil  -> send_resp(conn, 404, "")
      post -> send_json(conn, 200, post)
    end
  end

  match _ do
    send_not_found(conn)
  end

end
