ExUnit.start()

defmodule BlogTest.Case do
  @moduledoc """
  Sets up our standard test case when testing with the database.
  Wraps every test in transaction which is rolled back upon completion.
  """
  use ExUnit.CaseTemplate
  alias Ecto.Adapters.Postgres

  setup do
    Postgres.begin_test_transaction(Blog.Repo)
    on_exit fn ->
      Postgres.rollback_test_transaction(Blog.Repo)
    end
  end

  # When you use BlogTest.Case you also import it.
  using do
    quote do
      import BlogTest.Case
    end
  end
end
