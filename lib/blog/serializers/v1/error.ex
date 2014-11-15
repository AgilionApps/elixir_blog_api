defmodule Blog.Serializers.V1.Error do

  # temp hack for errors
  def as_json(_errors) do
      [
        %{
          type:   "error",
          attributes: %{
            code:   422,
            title:  "Invalid data"
          }
        }
      ]
  end

end
