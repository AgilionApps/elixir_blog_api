defmodule JsonApi.Responders do

  defmacro __using__(_) do
    quote do
      @serializer nil
      @error_serializer nil
      import JsonApi.Responders, only: [
        serializer: 1, error_serializer: 1,
        send_json: 3, not_found: 1, okay: 2, okay: 3, created: 2, invalid: 2
      ]
    end
  end

  @doc """
  Defines the serializer this modules responders will use to serialize json.
  """
  defmacro serializer(module) do
    quote do: @serializer unquote(module)
  end

  @doc """
  Defines a serializer to be used by invalid responders
  """
  defmacro error_serializer(module) do
    quote do: @error_serializer unquote(module)
  end

  defmacro send_json(conn, status, model) do
    quote bind_quoted: [conn: conn, status: status,  model: model] do
      JsonApi.Responders.send_json(conn, status, model, @serializer)
    end
  end

  defmacro okay(conn, model, meta) do
    quote bind_quoted: [conn: conn, model: model, meta: meta] do
      JsonApi.Responders.send_json(conn, 200, model, @serializer, meta)
    end
  end

  defmacro okay(conn, model) do
    quote bind_quoted: [conn: conn, model: model] do
      okay(conn, model, %{})
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

  def send_json(conn, status, model, serializer, meta \\ nil) do
    json = model
      |> serializer.as_json(conn, meta)
      |> Poison.Encoder.encode([])
    conn
      |> Plug.Conn.put_resp_header("content-type", "application/vnd.api+json")
      |> Plug.Conn.send_resp(status, json)
  end
end
