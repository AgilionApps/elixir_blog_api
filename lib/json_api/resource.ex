defmodule JsonApi.Resource do
  @moduledoc """
   TODO: Doc this.
  """

  defmacro __using__(opts) do
    quote do
      use Plug.Router
      use JsonApi.Responders
      use JsonApi.Params

      plug Plug.Parsers, parsers: [JsonApi.PlugParser]
      plug JsonApi.Resource.Nested

      opts = unquote(opts)
      @actions [:find_all, :find_many, :find_one, :create, :update, :delete]
      @allowed (opts[:only] || @actions -- (opts[:except] || []))

      unquote(JsonApi.Resource.use_action_behaviours)
    end
  end

  def use_action_behaviours do
    quote do
      if Enum.member?(@allowed, :find_all), do: use JsonApi.Resource.FindAll
      if Enum.member?(@allowed, :create),   do: use JsonApi.Resource.Create
      if Enum.member?(@allowed, :update),   do: use JsonApi.Resource.Update
      if Enum.member?(@allowed, :delete),   do: use JsonApi.Resource.Delete
      if Enum.member?(@allowed, :find_many) || Enum.member?(@allowed, :find_one) do
        use JsonApi.Resource.FindN
      end
    end
  end
end
