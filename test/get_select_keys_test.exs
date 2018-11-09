defmodule TinyEctoHelperMySQL.GetSelectKeysTest do
  use ExUnit.Case
  doctest TinyEctoHelperMySQL

  import Ecto.Query, warn: false

  alias TinyEctoHelperMySQL.Dummy

  @error_not_queryable {:error, :not_queryable}
  @error_no_select {:error, :not_found_select}

  describe "get_select_keys" do
    test "errors" do
      expect = @error_not_queryable
      assert TinyEctoHelperMySQL.get_select_keys() == expect

      [
        "",
        " ",
        1,
        [],
        {},
        %{},
        %{id: 1},
        false,
        true
      ]
      |> Enum.map(fn query ->
        assert TinyEctoHelperMySQL.get_select_keys(query) == expect
      end)
    end

    test "select not found" do
      expect = @error_no_select

      # no select
      query = from(d in Dummy)
      assert TinyEctoHelperMySQL.get_select_keys(query) == expect

      # empty select
      query =
        from(
          d in Dummy,
          select: {}
        )

      assert TinyEctoHelperMySQL.get_select_keys(query) == expect
    end

    test "select:ptn1" do
      # ptn1
      query =
        from(
          d in Dummy,
          select: {d.id, d.body, d.title, d.user_id}
        )

      expect = {:ok, [:id, :body, :title, :user_id]}
      assert TinyEctoHelperMySQL.get_select_keys(query) == expect
    end

    test "select:ptn2" do
      query =
        from(
          d in Dummy,
          select: {d.title, d.body, d.id, d.user_id, d.id, d.id}
        )

      expect = {:ok, [:title, :body, :id, :user_id, :id, :id]}
      assert TinyEctoHelperMySQL.get_select_keys(query) == expect
    end

    test "confirm AST" do
      query =
        from(
          d in Dummy,
          select: {d.id, d.body, d.title, d.user_id}
        )

      assert query.select.expr ==
               {:{}, [],
                [
                  {{:., [], [{:&, [], [0]}, :id]}, [], []},
                  {{:., [], [{:&, [], [0]}, :body]}, [], []},
                  {{:., [], [{:&, [], [0]}, :title]}, [], []},
                  {{:., [], [{:&, [], [0]}, :user_id]}, [], []}
                ]}
    end
  end
end
