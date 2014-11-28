defmodule JsonApi.Formatter.JsonApiOrg do
  alias JsonApi.Formatter.JsonApiOrg.Format
  alias JsonApi.Formatter.JsonApiOrg.Parser
  alias JsonApi.Serializer.Attributes
  alias JsonApi.Serializer.Relationships

  @moduledoc """
  Formats and parses between the jsonapi.org format and Elixir maps.
  """

  #TODO: Should impliment Formatter callback.
  @doc "Convience function for JsonApiOrg.Format.format"
  def format(model, serializer, conn, meta) do
    Format.format(model, serializer, conn, meta)
  end

  @doc "Convience function for JsonApiOrg.Parse.parse"
  def parse() do
    Parser.parse()
  end


  defmodule Parse do
    def parse do

    end
  end
end
