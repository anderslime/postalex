defmodule Postalex.Service.PostalCodeTest do
  use ExUnit.Case
  alias Postalex.Service.PostalCode
  require Logger

  test "summerize postalcodes" do
  	pc1 = %{name: "1", sums: [%{kind: "store", sum: 7}, %{kind: "office", sum: 1}, %{kind: "warehouse", sum: 11}]}
  	pc2 = %{name: "2", sums: [%{kind: "store", sum: 1}, %{kind: "office", sum: 3}]}
  	assert PostalCode.summarize([pc1, pc2]) == %{"office" => 4, "store" => 8, "warehouse" => 11}
  end

end
