defmodule Postalex.Service.Location do

  def find(country: country, category: category, postal_districts: postal_districts) do
    query = postal_codes_query(postal_districts, %{size: 1000})
    response = Elastix.Client.execute(:search, query, "#{country}_locations", "location")
    response["hits"]["hits"] |> Enum.map fn(res)-> map_to_loc(res) end
  end

  def postal_codes_query(postal_districts, options \\ %{size: 10}) do
    kinds = [:warehouse, :store, :office] # TODO generate automatically via arguments
    %{
      size: options.size,
      query: %{
        bool: %{
          must: [
            %{ terms: %{ postal_code: postal_districts } },
            %{ terms: %{ kind: kinds } },
            %{ match: %{ can_be_ordered: true}} # Change to => state: "active", when field present
          ]
        }
      }
    }
  end

  defp map_to_loc(res) do
    source = res["_source"]
    |> Map.delete("_id")
    |> Map.delete("_rev")
  end

end

# {
#   "_id" => "0b6ca93b-9ead-4316-bfac-bdbe0a090c7d",
#   "_index" => "dk_locations",
#   "_score" => 2.778896,
#   "_source" => %{
#     "_id" => "0b6ca93b-9ead-4316-bfac-bdbe0a090c7d",
#     "_rev" => "4-197ab6d16d9e700ea3e1a8c367653dfd",
#     "address_line_1" => "Skodsborgvej 305E",
#     "area_from" => 470.0,
#     "area_to" => nil,
#     "can_be_ordered" => true,
#     "created_at" => "2013-02-12T13:07:35.003+01:00",
#     "id" => 8671,
#     "kind" => "office",
#     "links" => %{"self" => %{"href" => "http://www.lokalebasen.dk/leje/kontorlokaler/2850-naerum/skodsborgvej-8671"}},
#     "location" => %{"lat" => 55.81642, "lon" => 12.531285},
#     "postal_code" => "2850",
#     "postal_name" => "Nærum",
#     "primary_photo" => "http://imageproxy2.lokalebasen.dk/convert?shape=cut&source=http%3A%2F%2Fc1315358.r58.cf3.rackcdn.com%2F149001%2FDSC02721.jpg&resize=400x280&signature=f8cd48cf9bf1a039a8c8241f313f955b",
#     "uuid" => "0b6ca93b-9ead-4316-bfac-bdbe0a090c7d",
#     "yearly_rent_per_m2_amount_from" => 850.0,
#     "yearly_rent_per_m2_amount_to" => nil},
#   "_type" => "location"
# }



