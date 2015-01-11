defmodule Postalex.Service.PostalCode do
  import CouchHelper

  @main_table "postal_codes"

  def all(ctry_cat, :without_sum) do
    %{ country: country, category: category } = ctry_cat
    cache_key = CacheHelper.cache_key(:without_sum, @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      fetch_postal_codes(country)
    end)
  end

  def all(ctry_cat, :with_sum) do
    %{ country: country, category: category } = ctry_cat
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
    |> add_sums(sums, HashDict.new)
  end

  defp add_sums([], sums, codes), do: codes
  defp add_sums([postal_code | postal_codes], sums, codes) do
    number = postal_code[:number]
    mp = merge_sum(postal_code, sums[number]) |> Map.delete(:type)
    codes = HashDict.put(codes, number, mp)
    add_sums(postal_codes, sums, codes)
  end

  defp remap(active_location_sum) do
    active_location_sum
    |> Enum.map fn(map) -> from_map(map) end
  end

  def postal_code_sums_by_kind(country, category) do
    index = "#{country}_#{category}_locations"
    type =  "location"
    query = Elastix.Location.Aggregation.by_postal_code_kind
    response = Elastix.Client.execute(:search, query, index, type)
    total = response["hits"]["total"]
    response["aggregations"]["postal_codes_kind"]["buckets"]
    |> buckets_to_pd_map(%{})
    |> Map.put(:total_locations, total)
  end

  defp buckets_to_pd_map([], pd_map), do: pd_map
  defp buckets_to_pd_map([bucket | buckets], pd_map) do
    pd_key = bucket["key"]
    kinds = bucket["kind"]["buckets"] |> Enum.map fn(kind)-> %{kind: kind["key"], sum: kind["doc_count"], number: pd_key} end
    buckets_to_pd_map(buckets, Map.put(pd_map, pd_key, kinds) )
  end

  defp from_map({[{_, [number, kind]},{ _ , sum}]}) do
    %{ number: number, sum: sum, kind: kind }
  end

  defp pc_from_map({[{"postal_name", postal_name},{"postal_code", postal_code},{"type", type}]}) do
    %{ number: postal_code, name: postal_name, type: type }
  end

  # TODO: Fetch from ES instead of couch
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
    cleaned = %{ sums: remove_field(sums, :number) }
    Map.merge(pc, cleaned)
  end

  defp remove_field(sums, field) do
    sums |> Enum.map fn(sum)-> Map.delete(sum, field) end
  end

end
