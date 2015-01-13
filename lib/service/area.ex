defmodule Postalex.Service.Area do
  import CouchHelper
  alias Postalex.Service.PostalDistrict

  @main_table "postal_areas"

  def all(country, category, []) do
    all_areas(country, category, [])
  end
  def all(country, category, postal_code_sums) do
    all_areas(country, category, postal_code_sums)
  end

  def summarized(ctry_cat, :by_district, postal_code_sums) do
    %{ country: country, category: category } = ctry_cat
    all(country, category, postal_code_sums)
  end

  def summarized(ctry_cat, :by_area, postal_code_sums) do
    %{ country: country, category: category } = ctry_cat
    all(country, category, postal_code_sums) |> summerize_postal_districts([])
  end

  defp summerize_postal_districts([], group), do: group
  defp summerize_postal_districts([area | areas], group) do
    sums = PostalDistrict.summarize(area.postal_districts)
    area = area
    |> Map.put(:sums, sums)
    |> Map.delete(:postal_districts)
    |> Map.delete(:type)
    summerize_postal_districts(areas, [ area | group] )
  end

  defp all_areas(country, category, []) do
    cache_key = CacheHelper.cache_key(category, @main_table)
    country |> ConCache.get_or_store(cache_key, fn() ->
      fetch_all_areas(country)
    end)
  end

  defp all_areas(country, category, postal_code_sums) do
    cache_key = CacheHelper.cache_key(category, @main_table)
    country |> ConCache.get_or_store(cache_key, fn() ->
      fetch_all_areas(country) |> add_postal_code_sums(postal_code_sums, [])
    end)
  end

  defp add_postal_code_sums([], _, areas_with_sums), do: areas_with_sums
  defp add_postal_code_sums([area | areas], postal_code_sums, areas_with_sums) do
    area_with_sums = add_sums(area, postal_code_sums)
    add_postal_code_sums(areas, postal_code_sums, [area_with_sums | areas_with_sums])
  end

  def fetch_all_areas(country) do
    country
    |> db_name(@main_table)
    |> database
    |> Couchex.fetch_view({"lists","all"},[])
    |> fetch_response
    |> to_docs
  end

  defp to_docs(res) do
    res |> Enum.map fn(map)-> value(map) |> to_area end
  end

  defp add_sums(area, postal_code_sums) do
    postal_districts = area.postal_districts |> PostalDistrict.add_sum_to_district(postal_code_sums, [])
    area |> Map.put(:postal_districts, postal_districts) |> Map.delete(:type)
  end

  defp to_area({[_,_,{"type", type},{"id", id},{"name", name},{"postal_districts", pds} | _]}) do
    pds = pds |> Enum.map fn(map)-> to_pd(map) end
    %{ type: type, id: id, name: name, postal_districts: pds}
  end

  defp to_pd({[{"type", type},{"name", name},{"id", id},{"postal_codes", postal_codes}]}) do
    postal_codes = postal_codes |> Enum.map fn(map)-> to_pc(map) end
    %{type: type, name: name, id: id, postal_codes: postal_codes}
  end

  defp to_pc({[{"postal_name", postal_name},{"postal_code", postal_code},{"type", type}]}) do
    %{postal_name: postal_name, postal_code: postal_code, type: type}
  end

end

