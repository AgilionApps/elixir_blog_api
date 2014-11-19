defmodule JsonApi.Responders do

  defmacro __using__(_) do
    quote do
      import JsonApi.Responders, only: [
        send_json: 3, not_found: 1, okay: 2, created: 2, invalid: 2
      ]
    end
  end

  defmacro send_json(conn, status, model) do
    quote bind_quoted: [conn: conn, status: status,  model: model] do
      JsonApi.Responders.send_json(conn, status, model, @serializer)
    end
  end

  defmacro okay(conn, model) do
    quote bind_quoted: [conn: conn, model: model] do
      JsonApi.Responders.send_json(conn, 200, model, @serializer)
    end
  end

  defmacro not_found(conn) do
    quote do: Plug.Conn.send_resp(unquote(conn), 404, "")
  end

  defmacro created(conn, model) do
    quote bind_quoted: [conn: conn, model: model] do
      location = apply(@serializer, :location, [model])
      conn
        |> Plug.Conn.put_resp_header("Location", location)
        |> JsonApi.Responders.send_json(201, model, @serializer)
    end
  end

  defmacro invalid(conn, errors) do
    quote bind_quoted: [conn: conn, errors: errors] do
      JsonApi.Responders.send_json(conn, 422, errors, @error_serializer)
    end
  end

  def send_json(conn, status, model, serializer) do
    json = model
      |> serializer.as_json(conn)
      |> Poison.Encoder.encode([])
    conn
      |> Plug.Conn.put_resp_header("content-type", "application/vnd.api+json")
      |> Plug.Conn.send_resp(status, json)
  end
end
