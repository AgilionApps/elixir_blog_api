defmodule Blog.Serializers.V1.Comment do
  use JsonApi.Serializer

  path "/v1/comments/:id"

  serialize "comments" do
    attributes [:id, :body]
    belongs_to :post, field: :post_id
  end
end
