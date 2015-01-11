defmodule Postalex.Service.PostalDistrict do
  alias Postalex.Service.PostalCode

  def summarize(postal_districts), do: postal_districts |> summarize(%{})

  def add_sum_to_district([], _pc_sums, pd_sums), do: pd_sums
  def add_sum_to_district([pd | pds], pc_sums, pd_sums) do
    pd = pd
    |> summarize_postal_codes(pc_sums)
    |> apply_sums(pd)
    add_sum_to_district(pds, pc_sums, [ pd | pd_sums ])
  end

  defp summarize([], sum), do: sum
  defp summarize([pd | pds], sum) do
    kinds = pd.sums |> Map.keys
    summarize(pds, merge(pd.sums, kinds, sum))
  end

  defp merge(_, [], res), do: res
  defp merge(sums, [kind | kinds], res) do
    sum = Map.get(sums, kind, 0) + Map.get(res, kind, 0)
    merge(sums, kinds, Map.put(res, kind, sum))
  end

  defp apply_sums(sums, postal_district) do
    postal_district
    |> Map.delete(:type)
    |> Map.delete(:postal_codes)
    |> Map.put(:sums, sums)
  end

  defp summarize_postal_codes(pd, pc_sums) do
    pd.postal_codes
    |> Enum.map(fn(pc)-> HashDict.get(pc_sums, pc.postal_code ) end)
    |> PostalCode.summarize
  end

end
