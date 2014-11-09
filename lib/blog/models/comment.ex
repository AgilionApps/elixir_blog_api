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

  def find(ids) when is_list(ids) do
    Repo.all(from m in __MODULE__, where: m.id in ^ids)
  end

  def find(id) when is_integer(id) do
    Repo.one(from m in __MODULE__, where: m.id == ^id)
  end

  def find(ids) when is_binary(ids) do
    ids = String.split(ids, ",") |> Enum.map &String.to_integer(&1)
    case ids do
      [id] -> find(id)
      ids  -> find(ids)
    end
  end

  def all do
    Repo.all(from m in __MODULE__, [])
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
