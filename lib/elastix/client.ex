defmodule Elastix.Client do

  def execute(:search, query, index, type) do
    response = post("#{elastic_url}/#{index}/#{type}/_search", query)
    response.body |> Poison.decode!
  end

  def execute(_, query, index, type), do: {:error, :undef_query_type}

  defp post(url, query) do
    HTTPotion.post(url,Poison.Encoder.encode(query, []))
  end

  defp elastic_url, do: System.get_env["ELASTIC_SERVER_URL"]

end
