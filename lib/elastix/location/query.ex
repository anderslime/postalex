defmodule Elastix.Location.Query do
  def postal_district_query(kinds, postal_districts, options \\ %{size: 1000}) do
    %{
      size: options.size,
      query: %{
        bool: %{
          must: [
            %{ terms: %{ postal_district_id: postal_districts } },
            %{ terms: %{ kind: kinds } },
            %{ match: %{ state: "active"}}
          ]
        }
      }
    }
  end

  @doc """
  bottom_left: %{ lat: 55.802848, lon: 12.50896 }
  top_right: %{  lat: 55.833961, lon: 12.570393 }
  """
  def bounding_box(kinds, bottom_left, top_right, options \\ %{size: 1000}) do
    %{
      size: options.size,
      query: %{
        filtered: %{
          query: %{
            bool: %{
              must: [
                %{ terms: %{ kind: kinds } },
                %{ match: %{ state: "active"}}
              ]
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
