defmodule Elastix.Location.Aggregation do

  def postal_code_sums_by_kind(country, category) do
    index = "#{country}_#{category}_locations"
    type =  "location"
    query = Elastix.Location.Aggregation.by_postal_code_kind
    response = Elastix.Client.execute(:search, query, index, type)
    total = response["hits"]["total"]
    response["aggregations"]["postal_codes_kind"]["buckets"]
    |> buckets_to_pd_map(%{})
    |> Map.put(:total_locations, total)
  end

  defp buckets_to_pd_map([], pd_map), do: pd_map
  defp buckets_to_pd_map([bucket | buckets], pd_map) do
    pd_key = bucket["key"]
    kinds = bucket["kind"]["buckets"] |> Enum.map fn(kind)-> %{kind: kind["key"], sum: kind["doc_count"], number: pd_key} end
    buckets_to_pd_map(buckets, Map.put(pd_map, pd_key, kinds) )
  end

  ##############
  # Aggregations

  def by_postal_code do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_codes: %{
          terms: %{ size: 0, field: :postal_code }
        }
      }
    }
  end

  def by_postal_district do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_districts: %{
          terms: %{ size: 0, field: :postal_district_id }
        }
      }
    }
  end

  def by_postal_code_kind do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_codes_kind: %{
          terms: %{ size: 0, field: :postal_code },
          aggs: %{ kind: %{ terms: %{ field: :kind } } }
        }
      }
    }
  end

  def by_postal_district_kind do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_district_kinds: %{
          terms: %{ size: 0, field: :postal_district_id },
          aggs: %{ kind: %{ terms: %{ field: :kind } } }
        }
      }
    }
  end

end


