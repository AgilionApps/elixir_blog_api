defmodule Blog.Adapters.JsonApi do
  require Inflex

  def adapt(models) do
    models
      |> Enum.reduce %{}, &format_models(&1, &2)
      |> camelize_keys
  end

  def format_models(%{type: type} = model, results) do
    model = format(model)
    Map.update(results, type, [model], &[model | &1])
  end

  def format(model) do
    model[:attributes]
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

  defp camelize(word) when is_atom(word),   do: Inflex.camelize(word, :lower)
  defp camelize(word) when is_binary(word), do: Inflex.camelize(word, :lower)
end

