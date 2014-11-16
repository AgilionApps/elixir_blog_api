defmodule JsonApi.Serializer do

  #TODO: break into relevant modules.

  @doc false
  defmacro __using__(_) do
    quote do

      Module.register_attribute __MODULE__, :attributes, persist: true
      @attributes []
      @relations []
      @key nil
      @location nil

      import JsonApi.Serializer, only: [serialize: 2, path: 1]

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
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:has_many, name, opts} | @relations]
    end
  end

  defmacro belongs_to(name, opts) do
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:belongs_to, name, opts} | @relations]
    end
  end

  defmacro path(path) do
    quote do
      @location unquote(path)
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

      def location(model) do
        JsonApi.Serializer.do_location(model, @location)
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

  def do_location(model, path) do
    {:ok, root_url} = Application.fetch_env(:json_api, :root_url)
    path = String.split(path, "/")
      |> Enum.map_join "/", &convert_location_path(&1, model)
    root_url <> path
  end

  def convert_location_path(":" <> frag, model) do
    "#{Map.get(model, String.to_atom(frag))}"
  end

  def convert_location_path(frag, _model), do: frag
end
