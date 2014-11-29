#TODO move file & directory to reflect singular module name.
defmodule JsonApi.Formatter.JsonApiOrg do
  alias JsonApi.Formatter.JsonApiOrg.Format
  alias JsonApi.Formatter.JsonApiOrg.Parse

  @moduledoc """
  Formats and parses between the jsonapi.org format and Elixir maps.
  """

  @doc "Convenience function for JsonApiOrg.Format.format"
  def format(model, serializer, conn, meta) do
    Format.format(model, serializer, conn, meta)
  end

  @doc "Convenience function for JsonApiOrg.Parse.parse"
  def parse(raw) do
    Parse.parse(raw)
  end

  defmodule Parse do
    def parse(raw) do
      JsonApi.ConvertKeys.underscore(raw)
    end
  end
end
