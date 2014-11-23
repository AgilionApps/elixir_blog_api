defmodule Blog.Api.V3.Comments do
  use Plug.Router
  use JsonApi.Responders
  use JsonApi.Params

  plug Plug.Parsers, parsers: [JsonApi.PlugParser]
  plug :match
  plug :dispatch
  alias Blog.Models.Comment

  serializer Blog.Serializers.V2.Comment
  error_serializer Blog.Serializers.V1.Error

  get "/" do
    okay(conn, Comment.all)
  end

  # Hack to deal with forwarding not passing match segments.
  def for_post(conn, post_id) do
    okay(conn, Comment.for_post(post_id))
  end
end
