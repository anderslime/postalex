defmodule Postalex.Service.Location do

  alias Postalex.Service.Area
  alias Postalex.Service.PostalCode

  def find(ctry_cat, kinds, postal_districts) do
    find(ctry_cat, kinds, postal_districts, default_clients)
  end
  def find(ctry_cat, kinds, postal_districts, clients) do
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, postal_districts)
  end

  def find_by_area_slug(ctry_cat, kinds, area_slug) do
    find_by_area_slug(ctry_cat, kinds, area_slug, default_clients)
  end
  def find_by_area_slug(ctry_cat, kinds, area_slug, clients) do
    area = Area.by_slug(ctry_cat, area_slug, clients)
    postal_districts = postal_district_ids(area_slug, area)
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, postal_districts)
  end

  def by_bounding_box(ctry_cat, kinds, bounding_box) do
    by_bounding_box(ctry_cat, kinds, bounding_box, default_clients)
  end
  def by_bounding_box(ctry_cat, kinds, bounding_box, clients) do
    clients.location_query.locations(:bounding_box, ctry_cat, kinds, bounding_box)
  end

  def district_locations_by_postal_code(ctry_cat, kinds, postal_code) do
    district_locations_by_postal_code(ctry_cat, kinds, postal_code, default_clients)
  end
  def district_locations_by_postal_code(ctry_cat, kinds, postal_code, clients) do
    pd_id = PostalCode.postal_district_id(ctry_cat, postal_code, clients)
    postal_districts_locations(ctry_cat, kinds, pd_id, clients)
  end

  defp postal_district_ids(area_slug, nil) do
    raise "Area with slug '#{area_slug}' not found"
  end

  defp postal_district_ids(_, area) do
    area.postal_districts |> Enum.map fn(pd)-> pd.id end
  end

  defp postal_districts_locations(ctry_cat, kinds, nil, _), do: %{ total: 0, locations: [], es_time_ms: -1 }
  defp postal_districts_locations(ctry_cat, kinds, postal_district, clients) do
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, [postal_district])
  end

  defp default_clients do
    %{
      location_query: Elastix.Location.Query,
      couch_client: CouchClient,
      location_aggregation: Elastix.Location.Aggregation
    }
  end

end
