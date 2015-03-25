defmodule Postalex.Service.LocationTest do
  use ExUnit.Case

  setup do
    cache_key = CacheHelper.cache_key("pc_dict", "postal_codes")
    ConCache.put(:dk, cache_key,
      HashDict.new |> HashDict.put("2850", "3751")
    )
    :ok
  end

  @ctry_cat %{country: :dk, category: :lease}
  @bounding_box %{
    bottom_left: %{ lat: 55.802848, lon: 12.50896 },
    top_right: %{  lat: 55.833961, lon: 12.570393 }
  }

  defmodule CouchClientMock do
    def areas(_country) do
      [
        {
          [
            {"id", "bornholm"},{"key", "bornholm"},
            {"value",
              {
                [
                  {"_id", "bornholm"}, {"_rev", "1-ac7def6742af1a0f9dabe19f4b40ad14"},
                  {"type", "area"}, {"id", "bornholm"}, {"name", "Bornholm"},
                  {"postal_districts",
                    [{[{"type", "postal_district"}, {"name", "Svaneke"}, {"id", "3740"},
                       {"postal_codes",
                        [{[{"postal_name", "Svaneke"}, {"postal_code", "3740"},
                           {"type", "postal_code"}]}]}, {"slug", "3740-svaneke"},
                       {"key", "svaneke"}]},
                     {[{"type", "postal_district"}, {"name", "Østermarie"}, {"id", "3751"},
                       {"postal_codes",
                        [{[{"postal_name", "Østermarie"}, {"postal_code", "3751"},
                           {"type", "postal_code"}]}]}, {"slug", "3751-ostermarie"},
                       {"key", "ostermarie"}]}
                    ]
                  },
                  {"slug", "bornholm"}
                ]
              }
            }
          ]
        }
      ]
    end
  end

  defmodule LocationQueryMock do
    @ctry_cat %{country: :dk, category: :lease}
    @kinds [:warehouse]
    @bounding_box %{
      bottom_left: %{ lat: 55.802848, lon: 12.50896 },
      top_right: %{  lat: 55.833961, lon: 12.570393 }
    }
    def locations(:postal_districts, @ctry_cat, @kinds, ["2850"], []) do
      ["LOCATIONS_BY_POSTAL_DISTRICT"]
    end
    def locations(:postal_districts, @ctry_cat, @kinds, ["3740", "3751"], []) do
      ["LOCATIONS_BY_AREA_SLUG"]
    end
    def locations(:bounding_box, @ctry_cat, @kinds, [], @bounding_box) do
      ["LOCATIONS_BY_BOUNDING_BOX"]
    end
  end

  defmodule PostalCodeMock do
    def postal_district_id(_, "2850", _), do: "2850"
  end

  @mock_clients %{
    couch_client: CouchClientMock,
    location_query: LocationQueryMock,
    location_aggregation: nil,
    postal_code_client: PostalCodeMock
  }

  test "find(ctry_cat, kinds, postal_districts)" do
    # Cyclomatic complexity of 1, we do not test
  end

  test "find_by_area_slug(ctry_cat, kinds, area_slug, clients)" do
    assert ["LOCATIONS_BY_AREA_SLUG"] ==
      Postalex.Service.Location.find_by_area_slug(@ctry_cat, [:warehouse], "bornholm", [], @mock_clients)
  end

  test "raise RuntimeError if Area not found by slug" do
    assert_raise RuntimeError, "Area with slug 'nordsjaelland' not found", fn ->
      Postalex.Service.Location.find_by_area_slug(@ctry_cat, [:warehouse], "nordsjaelland", [], @mock_clients)
    end
  end

  test "by_bounding_box(ctry_cat, kinds, bounding_box)" do
    assert ["LOCATIONS_BY_BOUNDING_BOX"] ==
      Postalex.Service.Location.by_bounding_box(@ctry_cat, [:warehouse], @bounding_box, [], @mock_clients)
  end

  test "district_locations_by_postal_code(ctry_cat, kinds, postal_code, clients)" do
    assert ["LOCATIONS_BY_POSTAL_DISTRICT"] ==
      Postalex.Service.Location.district_locations_by_postal_code(@ctry_cat, [:warehouse], "2850", [], @mock_clients)
  end

end
