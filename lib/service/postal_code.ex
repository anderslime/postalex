defmodule Postalex.Service.PostalCode do
  import CouchHelper

  def all(ctry_cat), do: all(ctry_cat, default_clients)
  def all(ctry_cat, clients ) do
    %{ country: country, category: category } = ctry_cat
    sums = clients.location_aggregation.postal_code_sums_by_kind(country, category)
    postal_codes(country, clients) |> add_sums(sums, HashDict.new)
  end

  def postal_district_id(ctry_cat, postal_code) do
    ctry_cat |> postal_district_id(postal_code, default_clients)
  end
  def postal_district_id(ctry_cat, postal_code, clients) do
    ctry_cat
      |> postal_codes_dict(clients)
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

  defp postal_codes(country, clients) do
    ConCache.get_or_store(country, "postal_codes", fn() ->
      clients.couch_client.postal_codes(country)
    end)
  end

  defp postal_codes_dict(%{ country: country, category: _}, clients) do
    ConCache.get_or_store(country, "postal_code_dict", fn() ->
      postal_codes(country, clients)
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
