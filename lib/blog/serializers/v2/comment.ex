defmodule Blog.Serializers.V2.Comment do
  use Relax.Serializer

  path "/v2/comment/:id"

  serialize "comments" do
    attributes [:id, :body]
    has_one :post
  end

  def post(model, _conn), do: model.post_id
end
