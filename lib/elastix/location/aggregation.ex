defmodule Elastix.Location.Aggregation do

  def by_postal_code do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_codes: %{
          terms: %{ size: 0, field: :postal_code }
        }
      }
    }
  end

  def by_postal_district do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_districts: %{
          terms: %{ size: 0, field: :postal_district_id }
        }
      }
    }
  end

  def by_postal_code_kind do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_codes_kind: %{
          terms: %{ size: 0, field: :postal_code },
          aggs: %{ kind: %{ terms: %{ field: :kind } } }
        }
      }
    }
  end

  def by_postal_district_kind do
    %{
      size: 0,
      query: %{ match: %{ state: "active" } },
      aggs: %{
        postal_district_kinds: %{
          terms: %{ size: 0, field: :postal_district_id },
          aggs: %{ kind: %{ terms: %{ field: :kind } } }
        }
      }
    }
  end

end


