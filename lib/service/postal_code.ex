defmodule Postalex.Service.PostalCode do
  import CouchResponse
  alias Postalex.Service

  def all(country) do
    String.to_atom(country)
    |> ConCache.get_or_store(:postal_codes, fn() ->
      all_postal_codes(country)
    end)
  end

  def active_location_sum(country) do
    String.to_atom(country)
    |> ConCache.get_or_store(:postal_codes, fn() ->
      _active_location_sum(country)
    end)
  end

  defp _active_location_sum(country) do

    postal_codes = all_postal_codes(country)
    {:ok, res} = "dk_active_locations"
      |> database
      |> Couchex.fetch_view({"groups","by_postal_code_kind"},[:group])
    list = res
    |> Enum.map fn(map) ->
      {[{_, [number, kind]},{ _ , sum}]} = map
      %{ number: number, sum: sum, kind: kind }
    end
    sums = Enum.group_by(list, fn(x)->x.number end)
    {_, pcs} = postal_codes
      |> Enum.map_reduce(%{}, fn(pc, map) ->
        mp = merge_sum(pc, sums[pc[:number]])
        { 0, Dict.put(map, pc[:number], mp) }
      end)
    pcs

  end

  def from_map(map) do
    {[{_,_id},{_,_rev},{_,number},{_,name},{_, municipalities}]} = map
    %{
      number: number,
      name: name
      # municipalities: municipalities |> Enum.map(fn(pd)-> Municipality.from_map(pd) end)
    }
  end

  defp all_postal_codes(country) do
    { :ok, list } = database("postal_codes") |> Couchex.fetch_view({"lists","all"},[])
    list |> map_values(&from_map/1)
  end

  defp merge_sum(pc, nil) do
    Map.merge(pc, %{ sums: [] })
  end

  defp merge_sum(pc, sums) do
    sums = sums |> Enum.map fn(sum)-> sum |> Map.delete(:number) end
    Map.merge(pc, %{ sums: sums })
  end

end