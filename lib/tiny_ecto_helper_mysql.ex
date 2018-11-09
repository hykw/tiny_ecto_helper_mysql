defmodule TinyEctoHelperMySQL do
  @moduledoc """
  Documentation for TinyEctoHelperMySQL
  """

  @doc """
  get columns lists in queryable

  from(
    q in Question,
    select: {q.id, q.title, q.body}
  ) |> TinyEctoHelperMySQL.get_select_keys()
    |
    |
    |
  [:id, :title, :body]
  """

  @error_not_queryable {:error, :not_queryable}
  @error_no_select {:error, :not_found_select}

  def get_select_keys(query) when is_map(query) do
    case get_select(query) do
      {:error, msg} ->
        {:error, msg}

      {:ok, select} ->
        {_, _, expr} = select.expr

        case expr do
          [] ->
            @error_no_select

          expr ->
            keys =
              expr
              |> Enum.map(fn x ->
                {{_, _, [_, key]}, _, _} = x
                key
              end)

            {:ok, keys}
        end
    end
  end

  def get_select_keys(_), do: get_select_keys()

  def get_select_keys() do
    @error_not_queryable
  end

  @doc """
  ## Examples
  Issue query to MySQL with queryable AND `SELECT SQL_CALC_FOUND_ROWS`, then return the result and the count returned from `SELECT FOUND_ROWS()` like following:

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
  """

  def query_and_found_rows(query, keys, [repo, struct, model]) do
    {:ok, [results, count]} =
      repo.transaction(fn ->
        [inject_sql, values] = build_inject_sql(repo, query)

        results =
          Ecto.Adapters.SQL.query!(repo, inject_sql, values).rows
          |> merge_result_keys(keys, [struct, model])

        [[count]] = Ecto.Adapters.SQL.query!(repo, "SELECT FOUND_ROWS()").rows

        [results, count]
      end)

    {:ok, %{results: results, count: count}}
  end

  defp get_select(query) when is_map(query) do
    if not Map.has_key?(query, :__struct__) do
      @error_not_queryable
    else
      select = Map.get(query, :select)

      # select exists, but it may be nil(e.g. select: {})
      if select == %{} or is_nil(select) do
        @error_no_select
      else
        {:ok, select}
      end
    end
  end

  defp get_select(_), do: @error_not_queryable

  defp build_inject_sql(repo, query) do
    {sql, values} = repo.to_sql(:all, query)
    inject_sql = String.replace_prefix(sql, "SELECT ", "SELECT SQL_CALC_FOUND_ROWS ")

    [inject_sql, values]
  end

  # build maps such as {id: 1, title: "xxxx"}
  defp merge_result_keys(raw_result, keys, [struct, model]) do
    raw_result
    |> Enum.map(fn x ->
      key =
        Enum.zip(keys, x)
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)

      # call validation just in case.
      true = model.changeset(struct, key).valid?
      Map.merge(struct, key)
    end)
  end
end
