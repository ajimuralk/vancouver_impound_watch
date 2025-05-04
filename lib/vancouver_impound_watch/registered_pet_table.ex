defmodule VancouverImpoundWatch.RegisteredPetTable do
  @moduledoc """
  An ETS table to keep track of fetched pet data.
  """
  use GenServer

  alias VancouverImpoundWatch.Pet

  @table :registered_pet_table

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table, [:named_table, :public])
    {:ok, :stateless}
  end

  @spec all() :: [{integer(), Pet.t()}]
  def all, do: :ets.tab2list(@table)

  @spec evict(integer()) :: true
  def evict(id), do: :ets.delete(@table, id)

  @spec insert(Pet.t()) :: true
  def insert(%{id: id} = record), do: :ets.insert(@table, {id, record})

  @spec lookup(Pet.t()) :: Pet.t() | nil
  def lookup(%{id: id}) do
    case :ets.lookup(@table, id) do
      [{^id, record}] ->
        record

      [] ->
        nil
    end
  end
end
