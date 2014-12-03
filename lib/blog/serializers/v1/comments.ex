defmodule Blog.Serializers.V1.Comment do
  use Relax.Serializer

  path "/v1/comments/:id"

  serialize "comments" do
    attributes [:id, :body]
    has_one :post, field: :post_id
  end
end
