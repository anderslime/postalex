defmodule Elastix.Location.Aggregation do

  def by_postal_code do
    %{
      aggs: %{
        postal_codes: %{
          terms: %{ size: 0, field: :postal_code }
        }
      }
    }
  end

  def by_postal_district do
    %{
      aggs: %{
        postal_districts: %{
          terms: %{ size: 0, field: :postal_district_id }
        }
      }
    }
  end

  def by_postal_code_kind do
    %{
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
      aggs: %{
        postal_district_kinds: %{
          terms: %{ size: 0, field: :postal_district_id },
          aggs: %{ kind: %{ terms: %{ field: :kind } } }
        }
      }
    }
  end

end
