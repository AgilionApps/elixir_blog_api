defmodule JsonApi.Responders do

  defmacro __using__(_) do
    quote do
      import JsonApi.Responders, only: [
        send_json: 3, not_found: 1, okay: 2, created: 2, invalid: 2
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

  defmacro created(conn, model) do
    quote do
      unquote(conn)
        |> Plug.Conn.put_resp_header("Location", "tbd")
        |> JsonApi.Responders.send_json(201, unquote(model), @serializer)
    end
  end

  defmacro invalid(conn, errors) do
    quote do
      JsonApi.Responders.send_json(unquote(conn), 422, unquote(errors), @error_serializer)
    end
  end

  def send_json(conn, status, model, serializer) do
    json = model
      |> serializer.as_json
      |> JsonApi.Encoder.encode
      |> Poison.Encoder.encode([])
    conn
      |> Plug.Conn.put_resp_header("content-type", "application/vnd.api+json")
      |> Plug.Conn.send_resp(status, json)
  end
end
