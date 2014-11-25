defmodule JsonApi.Encoder do
  require Inflex

  def encode(models) when is_list(models) do
    [f | _] = models
    %{}
      |> Map.put(f.type, Enum.map(models, &format(&1)))
      |> put_meta(f)
      |> put_linked(models)
      |> camelize_keys
  end

  def encode(model) when is_map(model) do
    %{}
      |> Map.put(model.type, format(model))
      |> put_meta(model)
      |> put_linked([model])
      |> camelize_keys
  end

  defp put_meta(results, model) do
    case Map.get(model, :meta) do
      nil                          -> results
      meta when map_size(meta) > 0 -> Map.put(results, "meta", meta)
      _                            -> results
    end
  end

  defp put_linked(results, models) do
    case extract_linked(models) do
      []     -> results
      linked -> Map.put(results, "linked", group_and_format(linked))
    end
  end

  defp extract_linked(models), do: extract_linked(models, [])
  defp extract_linked([], results), do: results
  defp extract_linked([model | models], results) do
    nested_linked = extract_linked(model.linked)
    extract_linked(models, nested_linked ++ model.linked ++ results)
  end

  defp group_and_format(models) do
    Enum.reduce models, %{}, fn(%{type: type} = model, results) ->
      model = format(model)
      Map.update(results, type, [model], &[model | &1])
    end
  end

  defp format(model) do
    Map.put(model[:attributes], :links, model[:relations])
  end

  defp camelize_keys(map) when is_map(map) do
    Enum.reduce map, %{}, fn({k, v}, a) ->
      Map.put(a, camelize(k), camelize_keys(v))
    end
  end

  defp camelize_keys(list) when is_list(list) do
    Enum.map list, &camelize_keys(&1)
  end

  defp camelize_keys(other), do: other

  defp camelize(word), do: Inflex.camelize(word, :lower)
end

