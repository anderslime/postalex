defmodule Postalex.Service.PostalDistrict do
  import CouchResponse
  alias Postalex.Service.Area

  def all(country) do
    {:ok, res} = "postal_districts" |> database |> Couchex.fetch_view({"lists","all"},[])
    res |> Enum.map fn(map) -> value(map) |> from_map end
  end

  def from_map(map) do
    {[{_,_id},{_,_rev},{_,postal_name},{_,postal_code},{_,from},{_,to},{_,neighbours},{_,areas},{_,slug}]} = map
    %{
      postal_name: postal_name,
      postal_code: postal_code,
      from: from,
      to: to,
      neighbours: neighbours |> Enum.map(fn(pd)-> to_postal_district_light(pd) end),
      areas: areas |> Enum.map(fn(pd)-> Area.from_map(pd) end),
      slug: slug
    }
  end

  defp to_postal_district_light(map) do
    {[{_,postal_name},{_,postal_code},{_,from},{_,to}]} = map
    %{postal_name: postal_name, postal_code: postal_code, from: from, to: to}
  end

end
