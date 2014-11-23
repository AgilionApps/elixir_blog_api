defmodule JsonApi.Resource do
  @moduledoc """
   TODO: Doc this.

  """

  defmacro __using__(_opts) do
    quote do
      use Plug.Router
      use JsonApi.Responders
      use JsonApi.Params

      @all_actions [:find_all, :find_many, :find_one, :create, :update, :delete]
      @actions @all_actions #todo, only & except from opts

      plug Plug.Parsers, parsers: [JsonApi.PlugParser]


      # what do we match on here?
      get "/" do
        find_all(var!(conn))
      end

      get "/:id_or_ids" do
        var!(id_or_ids)
        |> String.split(",")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&(String.to_integer(&1)))
        |> case do
          [id] -> find_one(var!(conn), id)
          ids  -> find_many(var!(conn), ids)
        end
      end

    end
  end
end
