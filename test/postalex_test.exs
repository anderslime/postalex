defmodule PostalexTest do
  use ExUnit.Case
  require Logger

  test "the truth" do
    # IO.inspect Postalex.Service.PostalDistrict.all(:dk,:lease, true) |> List.last
    # IO.inspect Postalex.Service.PostalDistrict.all(:dk,:lease, true) |> List.first
    # IO.inspect Postalex.Service.PostalCode.all(:dk, :lease, true)["2850"] #|> List.last
    # IO.inspect Postalex.Service.Area.summarized(:dk, :lease, []) |> List.last
    # IO.inspect Postalex.Service.Area.all(:dk, :lease) |> List.last
    # pcs_sum = PostalCode.all(:dk, :lease, :with_sum)
    # IO.inspect Postalex.Service.Area.all(:dk, :lease, pcs_sum) |> List.first
    # IO.inspect Postalex.Service.Area.summarized(:by_district, :dk, :lease, pcs_sum)
    # IO.inspect Postalex.Service.Area.summarized(:by_area, :dk, :lease, pcs_sum)
    # IO.inspect PostalCode.all(:se, :lease, :without_sum)
  end

  test "es" do
    # IO.inspect Postalex.Service.Location.find(country: :dk, category: :lease, postal_districts: ["2800", "2850"])
    kinds = [:warehouse]
    country = :dk
    category = :lease
    postal_districts = ["2800", "2850"]
    # query = postal_codes_query(kinds, postal_districts)
    # IO.inspect Postalex.Server.execute(:search, query, "#{country}_#{category}_locations", "location")
    # Postalex.Server.locations(country: country, category: category, kinds: [:warehouse], postal_districts: ["2800", "2850"])

    IO.inspect Postalex.Server.locations(%{country: country, category: category}, kinds: kinds, postal_districts: postal_districts)

  end

  def postal_codes_query(kinds, postal_districts, options \\ %{size: 10}) do
    kinds = [:warehouse, :store, :office] # TODO generate automatically via arguments
    %{
      size: options.size,
      query: %{
        bool: %{
          must: [
            %{ terms: %{ postal_district_id: postal_districts } },
            %{ terms: %{ kind: kinds } },
            %{ match: %{ can_be_ordered: true}} # Change to => state: "active", when field present
          ]
        }
      }
    }
  end
end
