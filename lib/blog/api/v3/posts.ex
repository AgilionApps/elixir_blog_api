defmodule Blog.Api.V3.Posts do
  use JsonApi.Resource
  alias Blog.Models.Post

  serializer Blog.Serializers.V3.Post
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

  # Hack to deal with forwarding not passing match segments.
  get ":post_id/comments" do
    Blog.Api.V3.Comments.for_post(conn, post_id)
  end
end
