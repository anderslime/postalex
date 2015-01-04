defmodule Municipality do
  def from_map(map) do
    {[{_,name},{_,code}]} = map
    %{name: name, code: code}
  end
end