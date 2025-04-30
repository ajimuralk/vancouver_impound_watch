defmodule VancouverImpoundWatch.RegisteredPetTable do
  @moduledoc """
  An ETS table to keep track of fetched pet data.
  """
  use GenServer
  @table :registered_pet_table

  def init(_) do
    :ets.new(@table, [:named_table])
    {:ok, :stateless}
  end

  def insert(%{id: id} = record), do: :ets.insert(@table, {id, record})

  def lookup(%{id: id}) do
    case :ets.lookup(@table, id) do
      {^id, record} ->
        record

      [] ->
        nil
    end
  end
end
