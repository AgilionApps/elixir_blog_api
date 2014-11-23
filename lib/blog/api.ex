defmodule Blog.Api do
  use JsonApi.Router

  plug :match
  plug :dispatch

  forward "/v2", to: Blog.Api.V2

  version :v1 do
    resource :posts,    Blog.Api.V1.Posts
    resource :comments, Blog.Api.V1.Comments
  end

  version :v3 do
    resource :posts,      Blog.Api.V1.Posts do
      resource :comments, Blog.Api.V1.Comments
    end
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end
