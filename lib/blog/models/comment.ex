defmodule Blog.Models.Comment do
  use    Ecto.Model
  import Ecto.Query, only: [from: 2]
  alias  Blog.Repo

  schema "comments" do
    field :body,       :string
    field :created_at, :datetime
    field :updated_at, :datetime

    belongs_to :post, Blog.Models.Post
  end

  validate comment,
    body:    present(),
    post_id: present()

  def find(id) do
    Repo.one(from t in __MODULE__, where: t.id == ^id)
  end

  @doc """
  Validates and creates a comment given a map of attributes
  """
  def create(params) do
    model = %__MODULE__{
      body:    params[:body],
      post_id: params[:post_id]
    }

    case validate(model) do
      []     -> {:ok,    Repo.insert(model)}
      errors -> {:error, errors}
    end
  end
end
