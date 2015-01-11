defmodule Elastix.Location.Query do
  def postal_district_query(kinds, postal_districts, options \\ %{size: 10}) do
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
end