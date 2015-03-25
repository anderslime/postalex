defmodule CouchHelper do

  def ping do
    server_connection |> Couchex.server_info |> parse_response
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
    Application.get_env(:postalex, :couch_server_url)
    |> Couchex.server_connection(credentials)
  end

  defp credentials do
    user = Application.get_env(:postalex, :couch_user)
    pass = Application.get_env(:postalex, :couch_pass)
    parse_credentials(user, pass)
  end

  defp parse_credentials(nil, _), do: []
  defp parse_credentials(user, pass), do: [{:basic_auth, {user, pass}}]

  defp parse_response({:error, _}), do: {:error, "couchdb"}
  defp parse_response({:ok,    _}), do: {:ok,    "couchdb"}

end
