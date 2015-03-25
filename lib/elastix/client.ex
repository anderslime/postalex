defmodule Elastix.Client do
  @elastic_url System.get_env["ELASTIC_SERVER_URL"]

  def ping do
    try do
      HTTPotion.get(@elastic_url)
      {:ok, "elastic"}
    rescue
      e in HTTPotion.HTTPError -> {:error, "elastic: #{e.message}"}
    end
  end

  def execute(:search, query, index, type) do
    "#{@elastic_url}/#{index}/#{type}/_search"
      |> post(query)
      |> body
      |> Poison.decode!
  end
  def execute(_, _, _, _), do: {:error, :undef_query_type}

  def mapping(index, type) do
    "#{@elastic_url}/#{index}/_mapping/#{type}"
    |> HTTPotion.get
    |> body
    |> Poison.decode!
  end

  defp post(url, query) do
    HTTPotion.post(url, Poison.Encoder.encode(query, []))
  end

  defp body(res), do: res.body
end
