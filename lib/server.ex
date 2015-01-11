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

  @doc """
  Returns all areas, summarized by area or postal district - group => :by_area or :by_district
  TODO: Data example
  """
  def areas(ctry_cat, group) do
    GenServer.call(__MODULE__, {:areas, ctry_cat, group})
  end


  @doc "Returns locations situated within postal districts of List"
  def locations(ctry_cat, kinds: kinds, postal_districts: postal_districts) do
    GenServer.call(__MODULE__, {:locations, ctry_cat, kinds: kinds, postal_districts: postal_districts })
  end

  @doc "Generic search query function"
  def execute(query_type, query, index, type) do
    GenServer.call(__MODULE__, {:execute_query, query_type, query, index, type })
  end

  ## Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:execute_query, query_type, query, index, type}, _from, state) do
    results = Elastix.Client.execute(query_type, query, index, type)
    {:reply, results, state}
  end

  def handle_call({:locations, ctry_cat, kinds: kinds, postal_districts: postal_districts}, _from, state) do
    results = Postalex.Service.Location.find(ctry_cat ,kinds, postal_districts)
    {:reply, results, state}
  end

  def handle_call({:areas, ctry_cat, group}, _from, state) do
    postal_code_sums = Postalex.Service.PostalCode.all(ctry_cat, :with_sum)
    areas = Postalex.Service.Area.summarized(ctry_cat, group, postal_code_sums)
    {:reply, areas, state}
  end

end