defmodule Blog.Adapters.JsonApi do
  require Inflex

  def adapt(models) do
    models
      |> format_models
      |> reorder_models
      |> camelize_keys
  end

  def format_models(models) do
    Enum.reduce models, %{}, &_format_models(&1, &2)
  end

  defp _format_models(%{type: type} = model, results) do
    model = format(model)
    Map.update(results, type, [model], &[model | &1])
  end

  def format(model) do
    Map.put(model[:attributes], :links, model[:relations])
  end

  def reorder_models(models) do
    Enum.reduce models, %{}, &_reorder_models(&1, &2)
  end

  defp _reorder_models({type, [model]}, results) do
    Map.put(results, type, model)
  end

  defp _reorder_models({type, models}, results) do
    Map.put(results, type, Enum.reverse(models))
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

