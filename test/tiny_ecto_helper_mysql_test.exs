defmodule TinyEctoHelperMysqlTest do
  use ExUnit.Case
  doctest TinyEctoHelperMysql

  test "greets the world" do
    assert TinyEctoHelperMysql.hello() == :world
  end
end
