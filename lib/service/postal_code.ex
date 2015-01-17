defmodule Postalex.Service.PostalCode do
  import CouchHelper

  @main_table "postal_codes"

  def all(ctry_cat, :without_sum) do
    clients = %{ couch_client: CouchClient }
    all(ctry_cat, :without_sum, clients)
  end
  def all(ctry_cat, :without_sum, clients) do
    %{ country: country, category: category } = ctry_cat
    cache_key = CacheHelper.cache_key(:without_sum, @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      clients.couch_client.postal_codes(country)
    end)
  end

  def all(ctry_cat, :with_sum) do
    clients = %{
      couch_client: CouchClient,
      location_aggregation: Elastix.Location.Aggregation
    }
    all(ctry_cat, :with_sum, clients)
  end
  def all(ctry_cat, :with_sum, clients ) do
    %{ country: country, category: category } = ctry_cat
    cache_key = CacheHelper.cache_key(:with_sum, category, @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      sums = clients.location_aggregation.postal_code_sums_by_kind(country, category)
      clients.couch_client.postal_codes(country) |> add_sums(sums, HashDict.new)
    end)
  end

  def postal_district_id(ctry_cat, postal_code) do
    pc = postal_codes_dict(ctry_cat)
      |> find_postal_code(postal_code)
    pc || pc.postal_district_id
  end

  defp find_postal_code(codes, postal_code) do
    codes[postal_code] || find_postal_district(codes, postal_code)
  end

  defp find_postal_district(codes, postal_code) do
    codes
      |> Dict.values
      |> Enum.find(fn(pc) -> pc.postal_district_id == postal_code end)
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

  defp from_map({[{_, [number, kind]},{ _ , sum}]}) do
    %{ number: number, sum: sum, kind: kind }
  end

  defp merge_sum(pc, nil), do: Map.merge(pc, %{ sums: [] })
  defp merge_sum(pc, sums) do
    cleaned = %{ sums: remove_field(sums, :number) }
    Map.merge(pc, cleaned)
  end

  defp remove_field(sums, field) do
    sums |> Enum.map fn(sum)-> Map.delete(sum, field) end
  end

  defp postal_codes_dict(ctry_cat) do
    %{ country: country, category: _ } = ctry_cat
    cache_key = CacheHelper.cache_key("pc_dict", @main_table)
    ConCache.get_or_store(country, cache_key, fn() ->
      {_, dict} = all(ctry_cat, :without_sum)
        |> Enum.map_reduce(HashDict.new, fn(x, acc)-> {0, HashDict.put(acc, x.number, x)}  end)
      dict
    end)
  end

end
