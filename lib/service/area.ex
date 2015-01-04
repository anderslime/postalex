defmodule Postalex.Service.Area do
  import CouchResponse
  alias Postalex.Service.PostalDistrict
  alias Postalex.Service.PostalCode

  def all(country) do
    sums = PostalCode.active_location_sum(country)
    districts = PostalDistrict.all(country)
    # PostalDistrict.all |> Enum.map(fn(pd)-> pd.areas end)
    district_sums(sums, districts)
  end


  defp district_sums(sums, districts) do



    districts |> Enum.map(fn(d)->
      Map.merge(d, %{range: String.to_integer(d.from)..String.to_integer(d.to), sum: 0})

    end)

    %{ d | sum: d.sum+p.sum }

    #   %{areas: [%{key: "nordjl", name: "Nordjylland"}], from: "9990",
    # neighbours: [%{from: "9900", postal_code: "9900",
    #    postal_name: "Frederikshavn", to: "9900"},
    #  %{from: "9850", postal_code: "9850", postal_name: "Hirtshals", to: "9850"},
    #  %{from: "9940", postal_code: "9940", postal_name: "Læsø", to: "9940"},
    #  %{from: "9982", postal_code: "9982", postal_name: "Ålbæk", to: "9982"}],
    # postal_code: "9990", postal_name: "Skagen", range: "9990".."9990",
    # slug: "9990-skagen", to: "9990"}

    # "postal_name": "Frederiksberg",
    # "postal_code": "2000",
    # "from": "2000",
    # "to": "2000",
    # "areas": [
    #    {
    #        "name": "Storkøbenhavn",
    #        "key": "kbh"
    #    }
    # ],
  end

  def from_map(map) do
    {[{_,name},{_,key}]} = map
    %{name: name, key: key}
  end

end