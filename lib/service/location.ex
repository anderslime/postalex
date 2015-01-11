defmodule Postalex.Service.Location do

  def find(ctry_cat, kinds, postal_districts) do
    %{ country: country, category: category } = ctry_cat
    index = "#{country}_#{category}_locations"
    type =  "location"
    opts = %{size: 1000}
    query = Elastix.Location.Query.postal_district_query(kinds, postal_districts, opts)
    response = Elastix.Client.execute(:search, query, index, type)
    response["hits"]["hits"] |> Enum.map fn(res)-> map_to_loc(res) end
  end

  defp map_to_loc(res) do
    res["_source"] |> Map.delete("_id") |> Map.delete("_rev")
  end

end
