defmodule Postalex.Server do
  use GenServer
  require Logger

  ## Client API

  @doc """
  Starts postal server.
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def ping do
    GenServer.call(__MODULE__, {:ping})
  end

  @doc """
  Returns all areas, summarized by area or postal district - group => :by_area or :by_district
  TODO: Data example
  """
  def areas(ctry_cat, group) do
    GenServer.call(__MODULE__, {:areas, ctry_cat, group})
  end

  def locations(ctry_cat, kinds: kinds, area_slug: area_slug) do
     GenServer.call(__MODULE__, {:locations, ctry_cat, kinds: kinds, area_slug: area_slug })
  end
  def locations(ctry_cat, kinds: kinds, postal_district_slug: postal_district_slug) do
     GenServer.call(__MODULE__, {:locations, ctry_cat, kinds: kinds, postal_district_slug: postal_district_slug })
  end

  @doc """
  Usage:
  bounding_box = %{ bottom_left: bottom_left, top_right: top_right }
  kinds = [:warehouse, :office]
  ctry_cat = %{country: :dk, category: :lease}
  locations(ctry_cat, kinds: kinds, bounding_box: bounding_box)
  """
  def locations(ctry_cat, kinds: kinds, bounding_box: bounding_box) do
    GenServer.call(__MODULE__, {:locations, ctry_cat, kinds: kinds, bounding_box: bounding_box })
  end

  @doc "Returns locations situated within postal districts of List"
  def locations(ctry_cat, kinds: kinds, postal_districts: postal_districts) do
    GenServer.call(__MODULE__, {:locations, ctry_cat, kinds: kinds, postal_districts: postal_districts })
  end

  @doc "Returns all locations of the district in which postal_code is situated"
  def district_locations(ctry_cat, kinds: kinds, postal_code: postal_code ) do
    GenServer.call(__MODULE__, {:district_locations, ctry_cat, kinds: kinds, postal_code: postal_code})
  end

  @doc "Generic search query function"
  def execute(query_type, query, index, type) do
    GenServer.call(__MODULE__, {:execute_query, query_type, query, index, type })
  end

  ## Server Callbacks
  def init(state) do
    Logger.info "Postalex.Server started"
    {:ok, state}
  end

  def handle_call({:ping}, _from, state) do
    {:reply, [CouchHelper.ping, Elastix.Client.ping], state}
  end

  def handle_call({:district_locations, ctry_cat, kinds: kinds, postal_code: postal_code}, _from, state) do
    results = Postalex.Service.Location.district_locations_by_postal_code(ctry_cat, kinds, postal_code)
    {:reply, results, state}
  end

  def handle_call({:execute_query, query_type, query, index, type}, _from, state) do
    results = Elastix.Client.execute(query_type, query, index, type)
    {:reply, results, state}
  end

  def handle_call({:locations, ctry_cat, kinds: kinds, area_slug: area_slug}, _from, state) do
    results = Postalex.Service.Location.find_by_area_slug(ctry_cat ,kinds, area_slug)
    {:reply, results, state}
  end

  def handle_call({:locations, ctry_cat, kinds: kinds, postal_district_slug: postal_district_slug}, _from, state) do
    postal_district = Postalex.Service.PostalDistrict.find_by_slug(ctry_cat, postal_district_slug)
    results = Postalex.Service.Location.find(ctry_cat ,kinds, [postal_district])
    {:reply, results, state}
  end

  def handle_call({:locations, ctry_cat, kinds: kinds, bounding_box: bounding_box}, _from, state) do
    results = Postalex.Service.Location.by_bounding_box(ctry_cat, kinds, bounding_box)
    {:reply, results, state}
  end

  def handle_call({:locations, ctry_cat, kinds: kinds, postal_districts: postal_districts}, _from, state) do
    results = Postalex.Service.Location.find(ctry_cat ,kinds, postal_districts)
    {:reply, results, state}
  end

  def handle_call({:areas, ctry_cat, group}, _from, state) do
    postal_code_sums = ctry_cat |> Postalex.Service.PostalCode.all(%{stale: true})
    areas = ctry_cat |> Postalex.Service.Area.summarized(group, postal_code_sums)
    {:reply, areas, state}
  end

end
