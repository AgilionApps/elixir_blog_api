defmodule Blog.Api.V1.Comments do
  import Plug.Conn
  use Plug.Router
  use JsonApi.Responders
  alias Blog.Models.Comment

  @serializer Blog.Serializers.V1.Comment

  plug :match
  plug :dispatch

  get "/" do
    send_json(conn, 200, Comment.all)
  end

  get "/:ids" do
    case Comment.find(ids) do
      nil   -> send_resp(conn, 404, "")
      posts -> send_json(conn, 200, posts)
    end
  end
end
