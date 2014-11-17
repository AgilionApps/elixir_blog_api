defmodule Blog.Api do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/v1", to: Blog.Api.V1
  forward "/v2", to: Blog.Api.V2

  match _ do
    send_resp(conn, 404, "")
  end
end
