defmodule Postalex.Service.PostalDistrict do
  alias Postalex.Service.PostalCode
  import CouchHelper

  def all(ctry_cat) do
    %{ country: country, category: _ } = ctry_cat
    ConCache.get_or_store(country, "postal_districts", fn() ->
      CouchClient.postal_districts(country)
    end)
  end

  def find_by_slug(ctry_cat, postal_district_slug) do
    all(ctry_cat) |> Enum.find fn(pd)-> pd.slug == postal_district_slug end
  end

  def summarize(pds),             do: summarize(pds, %{})
  defp summarize([], sum),        do: sum
  defp summarize([pd | pds], sum) do
    kinds = pd.sums |> Map.keys
    summarize(pds, merge(pd.sums, kinds, sum))
  end

  def add_sum_to_district([], _pc_sums, pd_sums),       do: pd_sums
  def add_sum_to_district([pd | pds], pc_sums, pd_sums) do
    pd = pd
      |> summarize_postal_codes(pc_sums)
      |> apply_sums(pd)
    add_sum_to_district(pds, pc_sums, [ pd | pd_sums ])
  end

  defp merge(_, [], res),               do: res
  defp merge(sums, [kind | kinds], res) do
    sum = Map.get(sums, kind, 0) + Map.get(res, kind, 0)
    merge(sums, kinds, Map.put(res, kind, sum))
  end

  defp apply_sums(sums, pd) do
    pd
      |> Map.drop([:postal_codes, :type])
      |> Map.put(:sums, sums)
  end

  defp summarize_postal_codes(pd, pc_sums) do
    pd.postal_codes
      |> Enum.map(fn(pc)-> HashDict.get(pc_sums, pc.postal_code ) end)
      |> PostalCode.summarize
  end

end
