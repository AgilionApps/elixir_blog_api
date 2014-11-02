defmodule Blog.Models.Post do
  use    Ecto.Model
  import Ecto.Query, only: [from: 2]
  alias  Blog.Repo

  schema "posts" do
    field :title,      :string
    field :body,       :string
    field :posted_at,  :datetime
    field :created_at, :datetime
    field :updated_at, :datetime
  end

  validate post,
    title: present(),
    body:  present()

  def find(id) do
    Repo.one(from t in __MODULE__, where: t.id == ^id)
  end

  @doc """
  Validates and creates a user given a map of attributes
  """
  def create(params) do
    user = %__MODULE__{
      title: params[:title],
      body:  params[:body]
    }

    case validate(user) do
      []     -> {:ok,    Repo.insert(user)}
      errors -> {:error, errors}
    end
  end
end
