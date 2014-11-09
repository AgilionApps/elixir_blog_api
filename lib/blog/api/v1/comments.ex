defmodule Blog.Api.V1.Comments do
  use JsonApi.Router
  alias Blog.Models.Comment

  serializer Blog.Serializers.V1.Comment

  get "/" do
    okay(conn, Comment.all)
  end

  get "/:ids" do
    case Comment.find(ids) do
      nil   -> not_found(conn)
      posts -> okay(conn, posts)
    end
  end
end
