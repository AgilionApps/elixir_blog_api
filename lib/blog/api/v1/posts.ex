defmodule Blog.Api.V1.Posts do
  import Plug.Conn
  use Plug.Router
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
    send_resp(conn, 404, "")
  end

  def send_json(conn, status, model) do
    json = model
      |> @serializer.as_json
      #|> Blog.Adapters.JsonApi.adapt
      |> Poison.Encoder.encode([])
    conn = put_resp_header(conn, "content-type", "application/vnd.api+json")
    send_resp(conn, status, json)
  end
end
