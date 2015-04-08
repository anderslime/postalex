defmodule Postalex.Service.PostalDistrictTest do
  use ExUnit.Case, async: false
  alias Postalex.Service.PostalDistrict
  require Logger

  import Mock

  test "summerize postaldistrics" do

    pd1 = %{
      id: "1000-1499-kobenhavn-k",
      name: "København K",
      sums: %{"office" => 281, "store" => 16, "warehouse" => 7},
      type: "postal_district"
    }

    pd2 = %{ id: "9990-skagen", name: "Skagen", sums: %{}, type: "postal_district"}
    pd3 = %{ id: "7800-skive", name: "Skive", sums: %{"store" => 3, "warehouse" => 5}, type: "postal_district"}
    assert PostalDistrict.summarize([pd1, pd2, pd3]) == %{"office" => 281, "store" => 19, "warehouse" => 12}
  end

  test "finds by postal district key" do
    virum = %{id: "2830", key: "virum"}
    kbh_n = %{id: "2100", key: "kobenhavn-n"}
    postal_districts = [virum, kbh_n]
    with_mock CouchClient, [postal_districts: fn(_) -> postal_districts end] do
      country_category = %{ category: nil, country: :dk }
      assert PostalDistrict.find_by_key(country_category, "virum") == virum
    end
  end

end
