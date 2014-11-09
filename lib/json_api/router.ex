defmodule JsonApi.Router do
  @moduledoc """
   TODO: Doc this.

  """

  defmacro __using__(_) do
    quote do
      use Plug.Router
      use JsonApi.Responders

      plug :match
      plug :dispatch

      @serializer nil
      import JsonApi.Router, only: [serializer: 1]
    end
  end

  @doc """
  Defines the serializer this router will use to serialize json.
  """
  defmacro serializer(module) do
    quote do: @serializer unquote(module)
  end
end
