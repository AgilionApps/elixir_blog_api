defmodule Blog.Serializers.V1.Post do
  use Blog.Serializer

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    #has_many :comments, ids: true, fn: :comment_ids
  end

  def is_published(model) do
    model.posted_at != nil
  end
end
