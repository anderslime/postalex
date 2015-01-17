defmodule Postalex.Service.Location do

  alias Postalex.Service.Area

  def find(ctry_cat, kinds, postal_districts) do
    _find(ctry_cat, kinds, postal_districts)
  end

  def find_by_area_slug(ctry_cat, kinds, area_slug) do
    area = Area.by_slug(ctry_cat, area_slug)
    _find(ctry_cat, kinds, postal_district_ids(area_slug, area))
  end

  defp postal_district_ids(area_slug, nil) do
    raise "Area with slug '#{area_slug}' not found"
  end
  defp postal_district_ids(_, area) do
    area.postal_districts |> Enum.map fn(pd)-> pd.id end
  end

  def by_bounding_box(ctry_cat, kinds, bounding_box) do
    { index, type } = index_type(ctry_cat)
    query = Elastix.Location.Query.bounding_box(kinds, bounding_box.bottom_left, bounding_box.top_right)
    Elastix.Client.execute(:search, query, index, type)
    |> location_response
  end

  def district_locations_by_postal_code(ctry_cat, kinds, postal_code) do
    pd_id = Postalex.Service.PostalCode.postal_district_id(ctry_cat, postal_code)
    postal_districts_locations(ctry_cat, kinds, pd_id)
  end

  defp postal_districts_locations(ctry_cat, kinds, nil), do: %{ total: 0, locations: [], es_time_ms: -1 }
  defp postal_districts_locations(ctry_cat, kinds, postal_district) do
    _find(ctry_cat, kinds, [postal_district])
  end

  defp _find(ctry_cat, kinds, postal_districts) do
    { index, type } = index_type(ctry_cat)
    query = Elastix.Location.Query.postal_district_query(kinds, postal_districts)
    Elastix.Client.execute(:search, query, index, type)
    |> location_response
  end

  defp location_response(response) do
    %{ total: total(response), locations: locations(response), es_time_ms: time(response) }
  end

  defp map_to_loc(res) do
    res["_source"] |> Map.delete("_id") |> Map.delete("_rev")
  end

  defp index_type(%{ country: country, category: category }) do
    { "#{country}_#{category}_locations", "location" }
  end
  defp total(response), do: response["hits"]["total"]
  defp time(response), do: response["took"]
  defp hits(response), do: response["hits"]["hits"]

  defp locations(response) do
    response |> hits |> Enum.map fn(res)-> map_to_loc(res) end
  end

end
