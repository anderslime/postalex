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

  @doc "Returns all areas, summarized by area or postal district - group => :by_area or :by_district"
  def areas(group, country, category) do
    GenServer.call(__MODULE__, {:areas, group, country, category})
  end

  @doc "Returns locations situated within postal districts of List"
  def locations(country: country, category: category, postal_districts: postal_districts) do
    GenServer.call(__MODULE__, {:locations, country: country, category: category, postal_districts: postal_districts })
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

  def handle_call({:locations, country: country, category: category, postal_districts: postal_districts}, _from, state) do
    results = Postalex.Service.Location.find(country: country, category: category, postal_districts: postal_districts)
    {:reply, results, state}
  end

  def handle_call({:areas, group, country, category}, _from, state) do
    postal_code_sums = Postalex.Service.PostalCode.all(country, category, :with_sum)
    areas = Postalex.Service.Area.summarized(group, country, category, postal_code_sums)
    {:reply, areas, state}
  end

end