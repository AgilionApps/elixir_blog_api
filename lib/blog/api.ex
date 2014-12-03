defmodule Blog.Api do
  use Relax.Router

  plug :match
  plug :dispatch

  # Standard plug forwarding and match still work.
  forward "/v2", to: Blog.Api.V2

  version :v1 do
    resource :posts,    Blog.Api.V1.Posts
    resource :comments, Blog.Api.V1.Comments
  end

  version :v3 do
    resource :posts, Blog.Api.V3.Posts do
      resource :comments, Blog.Api.V3.Post.Comments
    end
    resource :comments, Blog.Api.V3.Comments
  end

  match "status" do
    Plug.Conn.send_resp(conn, 200, "Alive")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end
