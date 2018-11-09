defmodule TinyEctoHelperMySQL.Dummy do
  ### Dummy module for UnitTest

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [usec: Mix.env() != :test]
  schema "questions" do
    field(:body, :string)
    field(:title, :string)
    field(:user_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body, :user_id])
    |> validate_number(:user_id, greater_than_or_equal_to: 1)
  end
end
