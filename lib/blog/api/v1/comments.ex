defmodule Blog.Api.V1.Comments do
  use JsonApi.Router
  alias Blog.Models.Comment

  serializer Blog.Serializers.V1.Comment
  error_serializer Blog.Serializers.V1.Error

  get "/" do
    okay(conn, Comment.all)
  end

  get "/:ids" do
    case Comment.find(ids) do
      nil      -> not_found(conn)
      comments -> okay(conn, comments)
    end
  end

  @post_params {"comments", [:body, {:post_id, "links.post"}]}

  post "/" do
    params = filter_params(conn, @post_params)
    case Comment.create(params) do
      {:ok,    comment} -> created(conn, comment)
      {:error, errors}  -> invalid(conn, errors)
    end
  end
end
