defmodule Blog.Serializers.V2.Comment do
  use JsonApi.Serializer

  path "/v2/comment/:id"

  serialize "comments" do
    attributes [:id, :body]
    belongs_to :post, ids: true
  end

  def post(model), do: model.post_id
end
