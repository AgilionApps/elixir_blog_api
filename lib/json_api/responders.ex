defmodule JsonApi.Responders do
  alias Plug.Conn

  defmacro __using__(_) do
    quote do
      import JsonApi.Responders, only: [send_json: 3, send_not_found: 1]
    end
  end

  #TODO: What about custom api dsl?

  # defmodule Api.V1.Posts do
  #   use JsonApi.Plug
  #   serializer Serializers.V1.Posts
  #
  #   get_json "/" do
  #     okay(Post.all)
  #   end
  #
  #   get_json ":id" do
  #     case Post.find(String.to_integer(id)) do
  #       nil  -> not_found
  #       post -> okay(post)
  #     end
  #   end
  #
  #   forward ":id/comments", to: Api.V1.Comments
  #
  # end

  #TODO: Refactor, move as much as possible to method
  # right now must be macro because of @serializer
  defmacro send_json(conn, status, model) do
    quote do
      json = unquote(model)
        |> @serializer.as_json
        |> Blog.Adapters.JsonApi.adapt
        |> Poison.Encoder.encode([])
      conn = put_resp_header(unquote(conn), "content-type", "application/vnd.api+json")
      send_resp(conn, unquote(status), json)
    end
  end

  defmacro send_not_found(conn) do
    quote do
      send_resp(unquote(conn), 404, "")
    end
  end
end
