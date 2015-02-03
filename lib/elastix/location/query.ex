defmodule Elastix.Location.Query do
  alias Elastix.Client, as: ESClient

  def locations(:postal_districts, ctry_cat, kinds, postal_districts) do
    %{ country: country, category: category } = ctry_cat
    query = postal_district_query(country, kinds, postal_districts)
    execute(query, index_type(ctry_cat))
  end

  def locations(:bounding_box, ctry_cat, kinds, bounding_box) do
    %{ country: country, category: category } = ctry_cat
    query = bounding_box(country, kinds, bounding_box.bottom_left, bounding_box.top_right)
    execute(query, index_type(ctry_cat))
  end

  defp execute(query, { index, type }) do
    ESClient.execute(:search, query, index, type)
      |> location_response
  end

  defp location_response(response) do
    %{ total: total(response), locations: locations(response), es_time_ms: time(response) }
  end

  @doc "Full location, including description etc"
  defp map_to_loc(res) do
     res["_source"] |> type_filter(["_id","_rev"])
  end

  @doc "Ligth location, for use in lists"
  defp map_to_loc_light(res) do
    res["_source"] |> type_filter(default_filter_types)
  end

  defp type_filter(location, []), do: location
  defp type_filter(location, [type|types]) do
    location |> Map.delete(type) |> type_filter(types)
  end

  defp default_filter_types do
    ["_id", "_rev", "description", "metadata", "area_ids", "type", "country"]
  end

  defp index_type(%{ country: country, category: category }) do
    { "locations", category }
  end
  defp total(response), do: response["hits"]["total"]
  defp time(response), do: response["took"]
  defp hits(response), do: response["hits"]["hits"]

  defp locations(response) do
    response |> hits |> Enum.map fn(res)-> map_to_loc_light(res) end
  end

  #######
  # Query

  def postal_district_query(country, kinds, postal_districts, options \\ %{size: 1000}) do
    %{
      size: options.size,
      query: %{
        bool: %{
          must: [
            %{ terms: %{ postal_district_id: postal_districts } },
            %{ terms: %{ kind: kinds } },
            %{ match: %{ country: country } },
          ],
          should: [
            %{ match: %{ state: "active" }},
            %{ match: %{ shown_as_rented_out: true }}
          ],
          minimum_should_match: 1
        }
      }
    }
  end

  @doc """
  bottom_left: %{ lat: 55.802848, lon: 12.50896 }
  top_right: %{  lat: 55.833961, lon: 12.570393 }
  """
  def bounding_box(country, kinds, bottom_left, top_right, options \\ %{size: 1000}) do
    %{
      size: options.size,
      query: %{
        filtered: %{
          query: %{
            bool: %{
              must: [
                %{ terms: %{ kind: kinds } },
                %{ match: %{ country: country } },
              ],
              should: [
                %{ match: %{ state: "active" }},
                %{ match: %{ shown_as_rented_out: true }}
              ],
              minimum_should_match: 1
            }
          },
          filter: %{
            geo_bounding_box: %{
              location: %{ bottom_left: bottom_left, top_right: top_right }
            }
          }
        }
      }
    }
  end

end
