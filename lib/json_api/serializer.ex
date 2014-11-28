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
    quote bind_quoted: [atts: atts] do
      # Save attributes
      @attributes @attributes ++ atts

      # Define default attribute function, make overridable
      for att <- atts do
        def unquote(att)(model, _conn), do: Map.get(model, unquote(att))
        defoverridable [{att, 2}]
      end
    end
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
        JsonApi.Formatter.JsonApiOrg.format(model, __MODULE__, conn, meta)
        # Relax.Serializer.Format.as_json(model, __MODULE__, conn, meta)
        # model
        #   |> JsonApi.Serializer.AbstractFormat.generate(__MODULE__, conn, meta)
        #   |> JsonApi.Encoder.encode
      end

      def location(model) do
        JsonApi.Serializer.Location.generate(model, __location)
      end
    end
  end

  defmodule Attributes do
    def get(serializer, model, conn) do
      Enum.reduce serializer.__attributes, %{}, fn(attr, results) ->
        Map.put(results, attr, apply(serializer, attr, [model, conn]))
      end
    end
  end

  defmodule Relationships do
    def nested(serializer, model, conn) do
      Enum.reduce serializer.__relations, %{}, fn({type, name, opts}, results) ->
        nested = nested_relation(serializer, model, conn, {type, name, opts})
        Map.put(results, name, nested)
      end
    end

    defp nested_relation(serializer, model, conn, {type, name, opts}) do
      if opts[:link] do
        %{href: JsonApi.Serializer.Location.generate(model, opts[:link])}
      else
        nested_ids(serializer, model, conn, {type, name, opts})
      end
    end

    # TODO: this could be better.
    defp nested_ids(serializer, model, conn, {_type, name, opts}) do
      fun = opts[:fn] || name
      models_or_ids = apply(serializer, fun, [model, conn])
      if opts[:serializer] do
        id_key = opts[:id_key] || :id
        models_or_ids = Enum.map models_or_ids, &(Map.get(&1, id_key))
      end
      models_or_ids
    end

    @doc """
      Gets all the resources included directly by the given serializer/model.

      Returns list of tuples {relation_key, serializer, model}
    """
    def included(serializer, parent, conn) do
      serializer.__relations
      |> Enum.filter(fn({_type, _name, opts}) -> opts[:serializer] end)
      |> Enum.flat_map &find_included(serializer, parent, conn, &1)
    end

    defp find_included(parent_serializer, parent, conn, {_, name, opts}) do
      fun = opts[:fn] || name
      apply(parent_serializer, fun, [parent, conn])
      |> Enum.map &({name, opts[:serializer], &1})
    end
  end

end
