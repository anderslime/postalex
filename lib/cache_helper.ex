defmodule CacheHelper do

  def cache_key(category, dbname), do: "#{category}_#{dbname}"
  def cache_key(prefix, category, dbname), do: "#{prefix}_#{category}_#{dbname}"

end
