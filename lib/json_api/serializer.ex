defmodule JsonApi.Serializer do

  @doc false
  defmacro __using__(_) do
    quote do

      Module.register_attribute __MODULE__, :attributes, persist: true
      @attributes []
      @relations []
      @key nil

      import JsonApi.Serializer, only: [serialize: 2]

      # Rune before compile hook before compiling
      @before_compile JsonApi.Serializer
    end
  end

  defmacro serialize(key, do: block) do
    quote do
      import JsonApi.Serializer, only: [attributes: 1, has_many: 2, belongs_to: 2]

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

  defmacro belongs_to(name, opts) do
    quote do
      @relations [{:belongs_to, unquote(name), unquote(opts)} | @relations]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def as_json(models) when is_list(models) do
        Enum.flat_map models, fn(model) ->
          JsonApi.Serializer.normalize(model, __MODULE__, @key, @attributes, @relations)
        end
      end

      def as_json(model) do
        JsonApi.Serializer.normalize(model, __MODULE__, @key, @attributes, @relations)
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
    Enum.reduce relations, %{}, fn({_type, name, opts}, results) ->
      relation_value = cond do
        opts[:ids] && opts[:fn] -> apply(module, opts[:fn], [model])
        opts[:ids]              -> apply(module, name, [model])
        #TODO: link urls
      end
      Map.put(results, name, relation_value)
    end
  end
end
