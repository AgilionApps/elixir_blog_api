defmodule JsonApi.Serializer do
  @moduledoc """
  TODO: Doc this well.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @attributes []
      @relations  []
      @key        nil

      import JsonApi.Serializer,          only: [serialize: 2]
      import JsonApi.Serializer.Location, only: [path: 1]

      @before_compile JsonApi.Serializer
    end
  end

  defmacro serialize(key, do: block) do
    quote do
      import JsonApi.Serializer, only: [
        attributes: 1, has_many: 2, belongs_to: 2
      ]

      @key unquote(key)
      unquote(block)
    end
  end

  defmacro attributes(atts) do
    quote do: @attributes @attributes ++ unquote(atts)
  end

  defmacro has_many(name, opts) do
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:has_many, name, opts} | @relations]
    end
  end

  defmacro belongs_to(name, opts) do
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:belongs_to, name, opts} | @relations]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def __attributes, do: @attributes
      def __key,        do: @key
      def __relations,  do: @relations
      def __location,   do: @location

      def as_json(model) do
        model
          |> JsonApi.Serializer.AbstractFormat.generate(__MODULE__)
          |> JsonApi.Encoder.encode
      end

      def location(model) do
        JsonApi.Serializer.Location.generate(model, __location)
      end
    end
  end
end
