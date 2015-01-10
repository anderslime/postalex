defmodule Postalex.Service.PostalCode do
  import CouchHelper

  @main_table "postal_codes"

  def all(country, _category, :without_sum) do
    cache_key = CacheHelper.cache_key(:without_sum, @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      fetch_postal_codes(country)
    end)
  end

  def all(country, category, :with_sum) do
    cache_key = CacheHelper.cache_key(:with_sum, category, @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      fetch_postal_codes_with_sum(country, category)
    end)
  end

  def summarize(postal_codes) do
    postal_codes |> summarize(%{})
  end

  defp summarize([], sum), do: sum
  defp summarize([pc | pcs], sum) do
    summarize(pcs, merge(pc.sums, sum))
  end

  defp merge([], res), do: res
  defp merge([sum | sums], res) do
    sum_res = Map.put(res, sum.kind, sum.sum + Map.get(res, sum.kind, 0))
    merge(sums, sum_res)
  end

  defp fetch_postal_codes_with_sum(country, category) do
    sums = postal_code_sums_by_kind(country, category)
    country
    |> fetch_postal_codes
    |> add_sums(sums)
  end

  defp add_sums(postal_codes, sums) do
    {_, pcs} = postal_codes
      |> Enum.map_reduce(%{}, fn(pc, map) ->
        mp = merge_sum(pc, sums[pc[:number]]) |> Map.delete(:type)
        { 0, Dict.put(map, pc[:number], mp) }
      end)
    pcs
  end

  defp remap(active_location_sum) do
    active_location_sum
    |> Enum.map fn(map) -> from_map(map) end
  end

  defp postal_code_sums_by_kind(country, category) do
    country
    |> db_name(category, "active_locations")
    |> database
    |> Couchex.fetch_view({"groups","by_postal_code_kind"},[:group])
    |> fetch_response
    |> remap
    |> Enum.group_by(fn(x)-> x.number end)
  end

  defp from_map({[{_, [number, kind]},{ _ , sum}]}) do
    %{ number: number, sum: sum, kind: kind }
  end

  defp pc_from_map({[{"postal_name", postal_name},{"postal_code", postal_code},{"type", type}]}) do
    %{ number: postal_code, name: postal_name, type: type }
  end

  defp fetch_postal_codes(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists","postal_codes"},[])
    |> fetch_response
    |> Enum.map fn(map)-> value(map) |> pc_from_map end
  end

  defp merge_sum(pc, nil), do: Map.merge(pc, %{ sums: [] })
  defp merge_sum(pc, sums) do
    sums = sums |> Enum.map fn(sum)-> sum |> Map.delete(:number) end
    Map.merge(pc, %{ sums: sums })
  end

end
