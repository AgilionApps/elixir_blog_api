defmodule Blog.Serializers.V1.Comment do
  use JsonApi.Serializer

  serialize "comments" do
    attributes [:id, :body]
    belongs_to :post, ids: true
  end

  def post(model), do: model.post_id
end
