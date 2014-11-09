defmodule Blog.Api.V1 do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/posts",    to: Blog.Api.V1.Posts
  forward "/comments", to: Blog.Api.V1.Comments

  match _ do
    send_resp(conn, 404, "")
  end
end
