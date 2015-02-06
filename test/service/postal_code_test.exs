defmodule Postalex.Service.PostalCodeTest do
  use ExUnit.Case, async: true
  alias Postalex.Service.PostalCode
  require Logger

  @pc1 %{
    name: "1",
    sums: [
      %{kind: "store", sum: 7},
      %{kind: "office", sum: 1},
      %{kind: "warehouse", sum: 11}
    ]
  }

  @pc2 %{
    name: "2",
    sums: [
      %{kind: "store", sum: 1},
      %{kind: "office", sum: 3}
    ]
  }

  @vejle_postal_number "7100"
  @vejle_district_id "7100"

  @vejle_pc_without %{ name: "Vejle", number: @vejle_postal_number, postal_district_id: @vejle_district_id, type: "postal_code"}

  @vejle_pc_with %{
    name: "Vejle",
    number: @vejle_postal_number,
    postal_district_id: @vejle_district_id,
    sums: [
      %{kind: "office", sum: 70},
      %{kind: "warehouse", sum: 36},
      %{kind: "store", sum: 18}
    ]
  }

  @ctry_cat %{country: :dk, category: :lease}

  defmodule CouchClientMock do
    def postal_codes(_country) do
      [ %{name: "Vejle", number: "7100", postal_district_id: "7100",type: "postal_code"} ]
    end
  end

  defmodule LocationAggregationMock do
    def postal_code_sums_by_kind(_country, _category) do
      %{:total_locations => 3408,
        "7100" => [
          %{kind: "office", number: "7100", sum: 70},
          %{kind: "warehouse", number: "7100", sum: 36},
          %{kind: "store", number: "7100", sum: 18}
        ]
      }
    end
  end

  @mock_clients %{ couch_client: CouchClientMock, location_aggregation: LocationAggregationMock }

  test "summerize postalcodes" do
    assert PostalCode.summarize([@pc1, @pc2]) == %{"office" => 4, "store" => 8, "warehouse" => 11}
  end

  test "fetch all postal codes with sum" do
    res = PostalCode.all(@ctry_cat, @mock_clients)
    assert res |> HashDict.keys == [@vejle_postal_number]
    assert res |> HashDict.values == [@vejle_pc_with]
  end

  test "get postal_district_id" do
    assert @vejle_district_id == PostalCode.postal_district_id(@ctry_cat, @vejle_postal_number, @mock_clients)
    assert nil == PostalCode.postal_district_id(@ctry_cat, "666", @mock_clients)
  end

end
