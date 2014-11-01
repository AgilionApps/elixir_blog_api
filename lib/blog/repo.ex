defmodule Blog.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, env: Mix.env

  def priv,      do: app_dir(:blog, "priv/repo")
  def conf(env), do: parse_url url(env)

  defp url(:dev),  do: "ecto://postgres@localhost/blog_dev"
  defp url(:test), do: "ecto://postgres@localhost/blog_test?size=1&max_overflow=0"
  defp url(:prod), do: "ecto://postgres@localhost/blog_prod"
end
