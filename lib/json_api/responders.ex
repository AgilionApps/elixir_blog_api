defmodule JsonApi.Responders do

  defmacro __using__(_) do
    quote do
      import JsonApi.Responders, only: [
        send_json: 3, not_found: 1, okay: 2
      ]
    end
  end

  defmacro send_json(conn, status, model) do
    quote do
      JsonApi.Responders.send_json(unquote(conn), unquote(status), unquote(model), @serializer)
    end
  end

  defmacro okay(conn, model) do
    quote do
      JsonApi.Responders.send_json(unquote(conn), 200, unquote(model), @serializer)
    end
  end

  defmacro not_found(conn) do
    quote do: Plug.Conn.send_resp(unquote(conn), 404, "")
  end

  def send_json(conn, status, model, serializer) do
    json = model
      |> serializer.as_json
      |> Blog.Adapters.JsonApi.adapt
      |> Poison.Encoder.encode([])
    conn
      |> Plug.Conn.put_resp_header("content-type", "application/vnd.api+json")
      |> Plug.Conn.send_resp(status, json)
  end
end
