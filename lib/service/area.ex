defmodule Postalex.Service.Area do
  import CouchHelper
  alias Postalex.Service.PostalDistrict

  def all(ctry, cat, pc_sums) do
    all(ctry, cat, pc_sums, default_clients)
  end
  def all(ctry, cat, pc_sums, clients) do
    all_areas(ctry, cat, pc_sums, clients)
  end

  def by_slug(ctry_cat, area_slug) do
    by_slug(ctry_cat, area_slug, default_clients)
  end
  def by_slug(ctry_cat, area_slug, clients) do
    %{ country: ctry, category: cat } = ctry_cat
    all_areas(ctry, cat, [], clients)
      |> Enum.find(fn(area)-> area.slug == area_slug end)
  end

  def summarized(ctry_cat, :by_district, pc_sums) do
    %{ country: ctry, category: cat } = ctry_cat
    all(ctry, cat, pc_sums)
  end

  def summarized(ctry_cat, :by_area, pc_sums) do
    %{ country: ctry, category: cat } = ctry_cat
    all(ctry, cat, pc_sums) |> summerize_postal_districts([])
  end

  defp summerize_postal_districts([], grp), do: grp
  defp summerize_postal_districts([area | areas], grp) do
    sums = PostalDistrict.summarize(area.postal_districts)
    area = area
      |> Map.put(:sums, sums)
      |> Map.drop([:postal_districts, :type])
    summerize_postal_districts(areas, [ area | grp] )
  end

  defp all_areas(ctry, cat, [], clients) do
    areas(ctry, cat, clients)
  end
  defp all_areas(ctry, cat, pc_sums, clients) do
    areas(ctry, cat, clients)
      |> add_postal_code_sums(pc_sums, [])
  end

  defp areas(ctry, _cat, clients) do
    ConCache.get_or_store(ctry, "postal_areas", fn() ->
      clients.couch_client.areas(ctry) |> to_docs
    end)
  end

  defp add_postal_code_sums([], _, areas_with_sums), do: areas_with_sums
  defp add_postal_code_sums([area | areas], pc_sums, areas_with_sums) do
    area_with_sums = add_sums(area, pc_sums)
    add_postal_code_sums(areas, pc_sums, [area_with_sums | areas_with_sums])
  end

  defp to_docs(res) do
    res |> Enum.map fn(map)-> value(map) |> to_map |> to_area end
  end

  defp add_sums(area, pc_sums) do
    pds = area.postal_districts |> PostalDistrict.add_sum_to_district(pc_sums, [])
    area |> Map.put(:postal_districts, pds) |> Map.delete(:type)
  end

  defp to_area(%{"id" => id, "type" => type, "name" => name, "slug" => slug, "postal_districts" => pds}) do
    pds = pds |> Enum.map fn(touple_list)-> touple_list |> to_map |> to_pd end
    %{type: type, id: id, slug: slug, name: name, postal_districts: pds}
  end

  defp to_pd(%{"type" => type, "name" => name, "id" => id, "postal_codes" => pcs, "slug" => slug, "key" => key}) do
    pcs = pcs |> Enum.map fn(touple_list)-> touple_list |> to_map |> to_pc end
    %{type: type, name: name, id: id, slug: slug, key: key, postal_codes: pcs}
  end

  defp to_pc(%{"postal_name" => pn, "postal_code" => pc, "type" => type}) do
    %{postal_name: pn, postal_code: pc, type: type}
  end

  defp default_clients, do: %{ couch_client: CouchClient }

  defp to_map({touples}) do
    touples |> Enum.into %{}
  end

end

