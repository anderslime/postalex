defmodule CouchHelper do

  def ping do
    server_connection |> Couchex.server_info |> _response
  end

  def value({[_,_,{_,value}]}), do: value

  def fetch_response({:ok, response}), do: response

  def db_name(country, dbname), do: "#{country}_#{dbname}"
  def db_name(country, category, dbname), do: "#{country}_#{category}_#{dbname}"

  def map_values(list, map_fun) do
    list |> Enum.map &(map_fun.(value(&1)))
  end

  def database(database_name) do
    server_connection |> Couchex.open_db(database_name) |> fetch_response
  end

  def server_connection do
    System.get_env["COUCH_SERVER_URL"]
      |> Couchex.server_connection(credentials)
  end

  defp credentials do
    user = System.get_env["COUCH_USER"]
    pass = System.get_env["COUCH_PASS"]
    parse_credentials(user, pass)
  end

  defp parse_credentials(nil, _), do: []
  defp parse_credentials(user, pass), do: [{:basic_auth, {user, pass}}]

  defp _response({:error, _}), do: {:error, "couchdb"}
  defp _response({:ok,    _}), do: {:ok,    "couchdb"}

end
