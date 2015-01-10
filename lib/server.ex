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

  def areas(group, country, category) do
    GenServer.call(__MODULE__, {:areas, group, country, category})
  end

  ## Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:areas, group, country, category}, _from, state) do
    postal_code_sums = Postalex.Service.PostalCode.all(country, category, :with_sum)
    areas = Postalex.Service.Area.summarized(group, country, category, postal_code_sums)
    {:reply, areas, state}
  end

end