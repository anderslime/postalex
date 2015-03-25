defmodule Postalex.Service.Location do

  alias Postalex.Service.Area
  alias Postalex.Service.PostalCode

  def find(ctry_cat, kinds, postal_districts, sort) do
    find(ctry_cat, kinds, postal_districts, sort, default_clients)
  end
  def find(ctry_cat, kinds, postal_districts, sort, clients) do
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, postal_districts, sort)
  end

  def find_by_area_slug(ctry_cat, kinds, area_slug, sort) do
    find_by_area_slug(ctry_cat, kinds, area_slug, sort, default_clients)
  end
  def find_by_area_slug(ctry_cat, kinds, area_slug, sort, clients) do
    area = Area.by_slug(ctry_cat, area_slug, clients)
    postal_districts = postal_district_ids(area_slug, area)
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, postal_districts, sort)
  end

  def by_bounding_box(ctry_cat, kinds, bounding_box, sort) do
    by_bounding_box(ctry_cat, kinds, bounding_box, sort, default_clients)
  end
  def by_bounding_box(ctry_cat, kinds, bounding_box, sort, clients) do
    clients.location_query.locations(:bounding_box, ctry_cat, kinds, sort, bounding_box)
  end

  def district_locations_by_postal_code(ctry_cat, kinds, postal_code, sort) do
    district_locations_by_postal_code(ctry_cat, kinds, postal_code, sort, default_clients)
  end
  def district_locations_by_postal_code(ctry_cat, kinds, postal_code, sort, clients) do
    pd_id = clients.postal_code_client.postal_district_id(ctry_cat, postal_code, clients)
    postal_districts_locations(ctry_cat, kinds, pd_id, sort, clients)
  end

  defp postal_district_ids(area_slug, nil) do
    raise "Area with slug '#{area_slug}' not found"
  end

  defp postal_district_ids(_, area) do
    area.postal_districts |> Enum.map fn(pd)-> pd.id end
  end

  defp postal_districts_locations(_, _, nil, _, _), do: %{ total: 0, locations: [], es_time_ms: -1 }
  defp postal_districts_locations(ctry_cat, kinds, postal_district, sort, clients) do
    clients.location_query.locations(:postal_districts, ctry_cat, kinds, [postal_district], sort)
  end

  defp default_clients do
    %{
      location_query: Elastix.Location.Query,
      couch_client: CouchClient,
      postal_code_client: PostalCode,
      location_aggregation: Elastix.Location.Aggregation
    }
  end

end
