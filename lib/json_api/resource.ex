defmodule JsonApi.Resource do
  @moduledoc """
   TODO: Doc this.
  """

  # All Possible actions

  defmacro __using__(opts) do
    quote do
      use Plug.Router
      use JsonApi.Responders
      use JsonApi.Params

      plug Plug.Parsers, parsers: [JsonApi.PlugParser]

      opts = unquote(opts)
      @actions [:find_all, :find_many, :find_one, :create, :update, :delete]
      @allowed_actions (opts[:only] || @actions -- (opts[:except] || []))

      unquote(JsonApi.Resource.generate_routes)
    end
  end

  def generate_routes do
    quote do
      if (Enum.member?(@allowed_actions, :find_all)) do
        get "/", do: var!(conn) |> JsonApi.Resource.set_parent |> find_all
      end

      if Enum.member?(@allowed_actions, :find_one) ||
          Enum.member?(@allowed_actions, :find_one) do
        unquote(JsonApi.Resource.find_one_and_many)
      end

      if (Enum.member?(@allowed_actions, :create)) do
        post "/", do: var!(conn) |> JsonApi.Resource.set_parent |> create
      end

      if (Enum.member?(@allowed_actions, :update)) do
        patch "/:id", do: var!(conn) |> JsonApi.Resource.set_parent |> update
        put   "/:id", do: var!(conn) |> JsonApi.Resource.set_parent |> update
        post  "/:id", do: var!(conn) |> JsonApi.Resource.set_parent |> update
      end

      if (Enum.member?(@allowed_actions, :delete)) do
        delete "/:id", do: var!(conn) |> JsonApi.Resource.set_parent |> delete
      end
    end
  end

  def find_one_and_many do
    quote do
      get "/:id_or_ids" do
        ids = var!(id_or_ids) |> String.split(",")
        find_many? = Enum.member?(@allowed_actions, :find_many)
        find_one? = Enum.member?(@allowed_actions, :find_one)
        case {find_many?, find_one?, ids} do
          {_, true, [id]} -> find_one(var!(conn), id)
          {true, _, ids}  -> find_many(var!(conn), ids)
        end
      end
    end
  end

  def set_parent(conn) do
    case {conn.private[:relax_parent_name], conn.private[:relax_parent_id]} do
      {nil, _}   -> conn
      {_, nil}   -> conn
      {name, id} -> Map.update(conn, :params, %{}, &(Map.put(&1, name, id)))
    end
  end
end
