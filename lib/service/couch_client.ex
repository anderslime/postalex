defmodule CouchClient do
  import CouchHelper

  def postal_codes(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists","postal_codes"},[])
    |> fetch_response
    |> Enum.map fn(map)-> value(map) |> pc_from_map end
  end

  def areas(country) do
    country
    |> db_name("postal_areas")
    |> database
    |> Couchex.fetch_view({"lists","all"},[])
    |> fetch_response
  end

  defp pc_from_map({[{"postal_name", postal_name},{"postal_code", postal_code},{"type", type},{"postal_district_id", postal_district_id}]}) do
    %{ number: postal_code, name: postal_name, type: type, postal_district_id: postal_district_id }
  end

end