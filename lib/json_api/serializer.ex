defmodule JsonApi.Serializer do
  @moduledoc """
  A DSL to define how a map or struct is serialized.

  Provides a set of macros to define what to serialize. For example:

      defmodule PostSerializer do
        use Relax.Serializer

        path "/v1/posts/:id"

        serialize "posts" do
          attributes [:id, :title, :body, :is_published]
          has_many :comments,    ids: true
          has_many :my_comments, link: "/v1/posts/:id/my_comments"
        end

        def is_published(post, _conn) do
          post.posted_at != nil
        end

        def comments(post, _conn) do
          Comments.by_post(post) |> Enum.map(&Map.get(&1, :id))
        end
      end

  A map or struct can then be passed to the serializer to return a the map now
  in the JsonApi.org format.

      post = %{id: 1, title: "Elixir is Sake", body: "yum", is_published: nil}
      PostSerializer.as_json(post, conn)

  This can then be passed to your JSON encoder of choice for encoding to a
  binary.
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

  @doc """
  Main API to define a serializer.
  """
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

      def as_json(model, conn, meta) do
        model
          |> JsonApi.Serializer.AbstractFormat.generate(__MODULE__, conn, meta)
          |> JsonApi.Encoder.encode
      end

      def location(model) do
        JsonApi.Serializer.Location.generate(model, __location)
      end
    end
  end
end
