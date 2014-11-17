defmodule JsonApi.Decoder do
  import Inflex, only: [underscore: 1]

  def decode(parsed_json) do
    parsed_json
    |> underscore_keys
  end

  defp underscore_keys(map) when is_map(map) do
    Enum.reduce map, %{}, fn({k, v}, a) ->
      Map.put(a, underscore(k), underscore_keys(v))
    end
  end

  defp underscore_keys(list) when is_list(list) do
    Enum.map list, &underscore_keys(&1)
  end

  defp underscore_keys(other), do: other
end
