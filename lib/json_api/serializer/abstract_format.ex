defmodule JsonApi.Serializer.AbstractFormat do
  def generate(models, module, conn, meta) when is_list(models) do
    Enum.map models, &generate(&1, module, conn, meta)
  end

  def generate(model, module, conn, meta) do
    # TODO: Any benefit to useing a struct here?
   %{
      type:       module.__key,
      meta:       meta,
      attributes: attribute_map(model, module, conn),
      relations:  nested_relations(model, module, conn),
      linked:     sideloaded_relations(model, module, conn)
    }
  end

  defp attribute_map(model, module, conn) do
    Enum.reduce module.__attributes, %{}, fn(attr, results) ->
      Map.put(results, attr, apply(module, attr, [model, conn]))
    end
  end

  # TODO: Can we improve relationship dsl to not need fn defined in common 
  # circumstances?
  defp nested_relations(model, module, conn) do
    Enum.reduce module.__relations, %{}, fn({type, name, opts}, results) ->
      relation_value = if opts[:link] do
        %{href: JsonApi.Serializer.Location.generate(model, opts[:link])}
      else
        nested_ids(model, module, conn, {type, name, opts})
      end
      Map.put(results, name, relation_value)
    end
  end

  defp nested_ids(model, module, conn, {_type, name, opts}) do
    fun = opts[:fn] || name
    models_or_ids = apply(module, fun, [model, conn])
    if opts[:serializer] do
      id_key = opts[:id_key] || :id
      models_or_ids = Enum.map models_or_ids, &(Map.get(&1, id_key))
    end
    models_or_ids
  end

  defp sideloaded_relations(model, module, conn) do
    module.__relations
      |> Enum.filter(fn({_type, _name, opts}) -> opts[:serializer] end)
      |> Enum.flat_map &sideload(model, module, conn, &1)
  end

  defp sideload(model, module, conn, {_type, name, opts}) do
    fun = opts[:fn] || name
    apply(module, fun, [model, conn]) |> generate(opts[:serializer], conn, %{})
  end
end
