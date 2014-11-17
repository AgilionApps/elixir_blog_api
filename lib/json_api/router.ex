defmodule JsonApi.Router do
  @moduledoc """
   TODO: Doc this.

  """

  defmacro __using__(_) do
    quote do
      use Plug.Router
      use JsonApi.Responders
      use JsonApi.Params

      plug Plug.Parsers, parsers: [JsonApi.PlugParser]
      plug :match
      plug :dispatch

      @serializer nil
      @error_serializer nil
      import JsonApi.Router, only: [serializer: 1, error_serializer: 1]
    end
  end

  @doc """
  Defines the serializer this router will use to serialize json.
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
end
