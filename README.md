# TinyEctoHelperMySQL

This is Tiny Ecto Helper for MySQL. At the moment, this module has the following functions.

1. get columns lists in queryable
2. Issue query to MySQL with queryable AND `SELECT SQL_CALC_FOUND_ROWS`, then return the result and the count returned from `SELECT FOUND_ROWS()` like following:

```
SELECT id, title FROM foo LIMIT 10 OFFSET 5;
   |
   |
   |
SELECT SQL_CALC_FOUND_ROWS id1, title FROM foo LIMIT 10 OFFSET 5;
SELECT FOUND_ROWS()
```

# Usage
- get columns lists in queryable

```
from(
  q in Question,
  select: {q.id, q.title, q.body}
) |> TinyEctoHelperMySQL.get_select_keys()
   |
   |
   |
[:id, :title, :body]
```

- Issue query to MySQL with queryable AND `SELECT SQL_CALC_FOUND_ROWS`, then return the result and the count returned from `SELECT FOUND_ROWS()` like following:
```
  query =
    from(
      q in Question,
      select: {q.id, q.title, q.body, q.user_id, q.inserted_at, q.updated_at},
      order_by: [asc: q.id]
    )

 {:ok, select_keys} = TinyEctoHelperMySQL.get_select_keys(query)
 TinyEctoHelperMySQL.query_and_found_rows(query, select_keys, [Repo, %Question{}, Question])
   |
   |
   |
{:ok, %{results: results, count: count}}
```

## Installation

As [available in Hex](https://hex.pm/packages/tiny_ecto_helper_mysql), the package can be installed
by adding `tiny_ecto_helper_mysql` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tiny_ecto_helper_mysql, "~> 1.0.0"}
  ]
end
```


## LICENSE

This software is released under the MIT License, see LICENSE.
