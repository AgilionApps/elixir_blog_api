defmodule JsonApi.Serializer.AbstractFormat do
  def generate(models, module) when is_list(models) do
    Enum.flat_map models, &generate(&1, module)
  end

  def generate(model, module) do
    # TODO: Any benefit to useing a struct here?
    generated = %{
      type:       module.__key,
      attributes: attribute_map(model, module),
      relations:  nested_relations(model, module)
    }
    [ generated | sideloaded_relations(model, module) ]
  end

  defp attribute_map(model, module) do
    Enum.reduce module.__attributes, %{}, fn(attr, results) ->
      case Map.fetch(model, attr) do
        {:ok, val} -> Map.put(results, attr, val)
        :error     -> Map.put(results, attr, apply(module, attr, [model]))
      end
    end
  end

  # TODO: Can we improve relationship dsl to not need fn defined in common 
  # circumstances?
  defp nested_relations(model, module) do
    Enum.reduce module.__relations, %{}, fn({type, name, opts}, results) ->
      relation_value = if opts[:link] do
        nil
      else
        nested_ids(model, module, {type, name, opts})
      end
      Map.put(results, name, relation_value)
    end
  end

  defp nested_ids(model, module, {_type, name, opts}) do
    fun = opts[:fn] || name
    models_or_ids = apply(module, fun, [model])
    if opts[:serializer] do
      id_key = opts[:id_key] || :id
      models_or_ids = Enum.map models_or_ids, &(Map.get(&1, id_key))
    end
    models_or_ids
  end

  defp sideloaded_relations(model, module) do
    module.__relations
      |> Enum.filter(fn({_type, _name, opts}) -> opts[:serializer] end)
      |> Enum.flat_map &sideload(model, module, &1)
  end

  defp sideload(model, module, {_type, name, opts}) do
    fun = opts[:fn] || name
    apply(module, fun, [model]) |> generate(opts[:serializer])
  end
end
