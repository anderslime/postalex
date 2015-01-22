defmodule Postalex.Service.Area do
  import CouchHelper
  alias Postalex.Service.PostalDistrict

  @key "postal_areas"

  def all(country, category, []) do
    all(country, category, [], default_clients)
  end
  def all(country, category, [], clients) do
    all_areas(country, category, [], default_clients)
  end

  def all(country, category, postal_code_sums) do
    all(country, category, postal_code_sums, default_clients)
  end
  def all(country, category, postal_code_sums, clients) do
    all_areas(country, category, postal_code_sums, clients)
  end

  def by_slug(ctry_cat, area_slug) do
    by_slug(ctry_cat, area_slug, default_clients)
  end
  def by_slug(ctry_cat, area_slug, clients) do
    %{ country: country, category: category } = ctry_cat
    all_areas(country, category, [], clients)
      |> Enum.find(fn(area)-> area.slug == area_slug end)
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

  defp all_areas(country, category, [], clients) do
    cache_key = CacheHelper.cache_key(category, @key)
    country |> ConCache.get_or_store(cache_key, fn() ->
      clients.couch_client.areas(country)
        |> to_docs
    end)
  end

  defp all_areas(country, category, postal_code_sums, clients) do
    cache_key = CacheHelper.cache_key(category, @key)
    country
      |> ConCache.get_or_store(cache_key, fn() ->
          clients.couch_client.areas(country) |> to_docs
        end)
      |> add_postal_code_sums(postal_code_sums, [])
  end

  defp add_postal_code_sums([], _, areas_with_sums), do: areas_with_sums
  defp add_postal_code_sums([area | areas], postal_code_sums, areas_with_sums) do
    area_with_sums = add_sums(area, postal_code_sums)
    add_postal_code_sums(areas, postal_code_sums, [area_with_sums | areas_with_sums])
  end

  defp to_docs(res) do
    res |> Enum.map fn(map)-> value(map) |> to_area end
  end

  defp add_sums(area, postal_code_sums) do
    postal_districts = area.postal_districts |> PostalDistrict.add_sum_to_district(postal_code_sums, [])
    area |> Map.put(:postal_districts, postal_districts) |> Map.delete(:type)
  end

  defp to_area({[_,_,{"type", type},{"id", id},{"name", name},{"postal_districts", pds},{"slug", slug} | _]}) do
    pds = pds |> Enum.map fn(map)-> to_pd(map) end
    %{ type: type, id: id, slug: slug, name: name, postal_districts: pds}
  end

  defp to_pd({[{"type", type},{"name", name},{"id", id},{"postal_codes", postal_codes},{"slug", slug},{"key", key}]}) do
    postal_codes = postal_codes |> Enum.map fn(map)-> to_pc(map) end
    %{type: type, name: name, id: id, slug: slug, key: key, postal_codes: postal_codes}
  end

  defp to_pc({[{"postal_name", postal_name},{"postal_code", postal_code},{"type", type}]}) do
    %{postal_name: postal_name, postal_code: postal_code, type: type}
  end

  defp default_clients, do: %{ couch_client: CouchClient }

end

