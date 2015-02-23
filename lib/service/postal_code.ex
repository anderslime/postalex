defmodule Postalex.Service.PostalCode do
  import CouchHelper

  def all(ctry_cat, %{stale: stale, couch_client: cc, location_aggregation: la}) do
    sums = stale |> postal_code_sums(ctry_cat, la)
    postal_codes(ctry_cat.country, cc) |> add_sums(sums, HashDict.new)
  end
  def all(ctry_cat, %{stale: stale}) do
    all(ctry_cat, Map.merge(default_clients, %{stale: stale}))
  end

  def postal_district_id(ctry_cat, postal_code) do
    ctry_cat |> postal_district_id(postal_code, default_clients)
  end
  def postal_district_id(ctry_cat, postal_code, clients) do
    ctry_cat
      |> postal_codes_dict(clients.couch_client)
      |> find_postal_code(postal_code)
      |> Map.get(:postal_district_id)
  end

  def summarize(postal_codes), do: postal_codes |> summarize(%{})
  defp summarize([], sum), do: sum
  defp summarize([pc | pcs], sum), do: summarize(pcs, merge(pc.sums, sum))

  defp find_postal_code(codes, postal_code) do
    codes[postal_code] || find_postal_district(codes, postal_code)
  end

  defp find_postal_district(codes, postal_code) do
    codes
      |> Enum.find(fn({_, pc}) -> pc.postal_district_id == postal_code end)
      |> code
  end

  defp code(nil),     do: %{}
  defp code({_, pc}), do: pc

  defp merge([], res), do: res
  defp merge([sum | sums], res) do
    new_sum = sum.sum + Map.get(res, sum.kind, 0)
    sums |> merge(Map.put(res, sum.kind, new_sum))
  end

  defp add_sums([], sums, codes),                           do: codes
  defp add_sums([postal_code | postal_codes], sums, codes)  do
    number = postal_code[:number]
    mp = merge_sum(postal_code, sums[number]) |> Map.delete(:type)
    add_sums(postal_codes, sums, HashDict.put(codes, number, mp))
  end

  defp merge_sum(pc, sums) do
    Map.merge(pc, %{ sums: remove_field(sums, :number) })
  end

  defp remove_field(nil, field), do: []
  defp remove_field(sums, field) do
    sums |> Enum.map(fn(sum)-> Map.delete(sum, field) end)
  end

  defp postal_codes(country, couch_client) do
    ConCache.get_or_store(country, "postal_codes", fn() ->
      couch_client.postal_codes(country)
    end)
  end

  defp postal_code_sums(true, %{country: country, category: category}, location_aggregation) do
    sums = ConCache.get_or_store(country, "postal_code_sums_#{category}", fn() ->
      postal_code_sums(false, %{country: country, category: category}, location_aggregation)
    end)
    spawn(Postalex.Service.PostalCode, :update_sums_cache, [country, category, location_aggregation])
    sums
  end
  defp postal_code_sums(false, %{country: country, category: category}, location_aggregation) do
    location_aggregation.postal_code_sums_by_kind(country, category)
  end

  def update_sums_cache(country, category, location_aggregation) do
    sums = location_aggregation.postal_code_sums_by_kind(country, category)
    ConCache.put(country, "postal_code_sums_#{category}", sums)
  end

  defp postal_codes_dict(%{ country: country, category: _}, couch_client) do
    ConCache.get_or_store(country, "postal_code_dict", fn() ->
      postal_codes(country, couch_client)
        |> Enum.reduce(HashDict.new, fn(x, acc)-> HashDict.put(acc, x.number, x)  end)
    end)
  end

  defp default_clients do
    %{
      couch_client: CouchClient,
      location_aggregation: Elastix.Location.Aggregation
    }
  end

end
