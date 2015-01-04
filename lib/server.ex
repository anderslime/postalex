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

  def postal_code(country, postal_code) do
    GenServer.call(__MODULE__, {:postal_code, country, postal_code})
  end

  def postal_district(country, postal_code) do
    GenServer.call(__MODULE__, {:postal_districts, country, postal_code})
  end

  ## Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:postal_codes, country, category}, _from, state) do
    postal_codes = ConCache.get(String.to_atom(country), :postal_codes) |> Map.values
    {:reply, postal_codes, state}
  end

end