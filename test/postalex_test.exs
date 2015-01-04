defmodule PostalexTest do
  use ExUnit.Case

  test "the truth" do

    # couchdb_url = System.get_env["COUCH_SERVER_URL"]
    # server = Couchex.server_connection(couchdb_url, [{:basic_auth, {"thomas", "secret"}}])
    # {:ok, db} = Couchex.open_db(server, "testdb")
    # {:ok, db} = Couchex.open_db(server, "postal_codes")
    # {:ok, res} = Couchex.all(db)
    # {:ok, doc} = Couchex.open_doc(db, "2850")
    # IO.inspect doc


    # {:ok, db} = Couchex.open_db(server, "dk_active_locations")
    # {:ok, res} = Couchex.fetch_view(db, {"groups","by_postal_code"},[:group])
    # IO.inspect res
    # IO.inspect PostalDistrict.all
    # IO.inspect PostalCode.all
    # IO.inspect PostalCode.active_location_sum
    # sums = PostalCode.active_location_sum
    # IO.inspect sums
    IO.inspect Postalex.Service.Area.all("dk") |> List.last
  end
end
