defmodule CouchClient do
  import CouchHelper

  # TODO Make to GenServer

  def postal_codes(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists", "postal_codes"}, [])
    |> fetch_response
    |> Enum.map fn(map)-> value(map) |> pc_from_map end
  end

  def postal_districts(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists", "postal_districts"}, [])
    |> fetch_response
    |> Enum.map fn(map)-> value(map) |> pd_from_map end
  end

  def postal_districts_with_postal_codes(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists", "postal_districts_with_postal_codes"}, [])
    |> fetch_response
    |> pd_response_to_pds_with_postal_codes
    |> Enum.uniq
  end

  def areas(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists", "all"}, [])
    |> fetch_response
  end

  defp pc_from_map({[{"postal_name", postal_name}, {"postal_code", postal_code}, {"type", type}, {"postal_district_id", postal_district_id}]}) do
    %{ number: postal_code, name: postal_name, type: type, postal_district_id: postal_district_id }
  end

  defp pd_from_map({[{"id", id}, {"name", name}, {"slug", slug}, {"key", key}]}) do
    %{ id: id, name: name, slug: slug, key: key }
  end

  defp pd_response_to_pds_with_postal_codes(response) do
    response
    |> Enum.map &(value(&1))
    |> tuple_to_map
    |> pd_with_postal_codes_from_map
  end

  defp pd_with_postal_codes_from_map(postal_district) do
    postal_district
    |> Map.put "postal_codes", normalized_postal_codes(postal_district)
  end

  defp normalized_postal_codes(postal_district) do
    Map.fetch!(postal_district, "postal_codes")
    |> Enum.map &(tuple_to_map(&1))
  end

  defp tuple_to_map({tuple_list}) do
    Enum.into tuple_list, %{}
  end
end
