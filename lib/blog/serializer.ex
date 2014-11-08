defmodule Blog.Serializer do

  @doc false
  defmacro __using__(_) do
    quote do
      import Blog.Serializer, only: [serialize: 2]

      @attributes []
      @relations []

      # Rune before compile hook before compiling
      @before_compile Blog.Serializer
    end
  end

  defmacro serialize(key, do: block) do
    quote do
      import Blog.Serializer, only: [attributes: 1, has_many: 2]

      @key unquote(key)
      unquote(block)
    end
  end

  defmacro attributes(atts) do
    quote do
      # Add attributes to existing attributes array
      @attributes @attributes ++ unquote(atts)
    end
  end

  defmacro has_many(name, opts) do
    quote do
      @relations [{:has_many, unquote(name), unquote(opts)} | @relations]
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    quote do
      def as_json(models) when is_list(models) do
        Enum.flat_map models, fn(model) ->
          Blog.Serializer.normalize(model, __MODULE__, @key, @attributes, @relations)
        end
      end

      def as_json(model) do
        Blog.Serializer.normalize(model, __MODULE__, @key, @attributes, @relations)
      end
    end
  end

  def normalize(model, module, key, attributes, relations) do
    [%{
      type: key,
      attributes: attribute_map(model, module, attributes),
      relations: relations_map(model, module, relations)
    }]
  end

  defp attribute_map(model, module, attributes) do
    Enum.reduce attributes, %{}, fn(attr, results) ->
      case Map.fetch(model, attr) do
        {:ok, val} -> Map.put(results, attr, val)
        :error     -> Map.put(results, attr, apply(module, attr, [model]))
      end
    end
  end

  defp relations_map(model, module, relations) do
    Enum.reduce relations, %{}, fn({type, name, opts}, results) ->
      relation_value = cond do
        opts[:ids] && opts[:fn] -> apply(module, opts[:fn], [model])
        opts[:ids]              -> apply(module, name, [model])
        #TODO: link urls
      end
      Map.put(results, name, relation_value)
    end
  end
end
