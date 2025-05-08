defmodule VancouverImpoundWatch.SchedulerTest do
  @moduledoc """
  Test for scheduling calls to fetch and publish API data using a stubbed Fetch module. 
  """

  use ExUnit.Case, async: true

  alias VancouverImpoundWatch.RegisteredPetTable
  alias VancouverImpoundWatch.Scheduler

  defmodule MockFetcher do
    @behaviour VancouverImpoundWatch.Fetcher.Behaviour
    use Agent

    def start_link(opts \\ []) do
      Agent.start_link(fn -> opts end, name: __MODULE__)
    end

    def set_pets(pets), do: Agent.update(__MODULE__, fn _ -> pets end)
    def get, do: {:ok, Agent.get(__MODULE__, & &1)}
  end

  describe "fetch" do
    setup do
      start_supervised!(VancouverImpoundWatch.RegisteredPetTable)
      start_supervised!(MockFetcher)

      {:ok, pid} =
        Scheduler.start_link(
          fetcher: MockFetcher,
          # effectively disables auto-fetch in test
          fetch_interval_in_secs: 1_000_000
        )

      MockFetcher.set_pets([pet1(), pet2()])

      :ets.delete_all_objects(:registered_pet_table)

      {:ok, scheduler: pid}
    end

    test "it fetches, handles, and caches valid records", %{scheduler: scheduler} do
      send(scheduler, :fetch)
      Process.sleep(50)

      %{id: pet1_id} = pet1()
      %{id: pet2_id} = pet2()

      for id <- [pet1_id, pet2_id] do
        assert %{id: ^id} = RegisteredPetTable.lookup(%{id: id})
      end
    end

    test "cleanup_cache evicts pets with updated terminal status", %{scheduler: scheduler} do
      send(scheduler, :fetch)
      Process.sleep(50)

      %{id: pet1_id} = pet1()
      %{id: pet2_id} = pet2()

      for id <- [pet1_id, pet2_id] do
        assert %{id: ^id} = RegisteredPetTable.lookup(%{id: id})
      end

      MockFetcher.set_pets([pet1_updated(), pet2_updated()])
      send(scheduler, :fetch)
      Process.sleep(50)

      send(scheduler, :cleanup_cache)
      Process.sleep(50)

      for id <- [pet1_id, pet2_id] do
        assert is_nil(RegisteredPetTable.lookup(%{id: id}))
      end
    end
  end

  defp pet1 do
    %VancouverImpoundWatch.Pet{
      aco: "43",
      age_category: :adult,
      id: 35_320,
      approx_weight: nil,
      breed: "yorkie",
      code: nil,
      color: "Grey & tan",
      date_impounded: ~D[2025-04-16],
      disposition_date: ~D[2025-04-16],
      kennel_number: "200",
      last_updated: ~D[2025-05-04],
      name: "Chloe",
      pit_number: nil,
      sex: :female,
      source: :holding_stray,
      status: "reported"
    }
  end

  defp pet1_updated do
    %VancouverImpoundWatch.Pet{
      aco: "43",
      age_category: :adult,
      id: 35_320,
      approx_weight: nil,
      breed: "yorkie",
      code: nil,
      color: "Grey & tan",
      date_impounded: ~D[2025-04-16],
      disposition_date: ~D[2025-04-16],
      kennel_number: "200",
      last_updated: ~D[2025-05-04],
      name: "Chloe",
      pit_number: nil,
      sex: :female,
      source: :holding_stray,
      status: "redeemed"
    }
  end

  defp pet2 do
    %VancouverImpoundWatch.Pet{
      aco: "40",
      age_category: :adult,
      id: 35_322,
      approx_weight: nil,
      breed: "miniature poodle",
      code: nil,
      color: "Brown",
      date_impounded: ~D[2025-04-16],
      disposition_date: ~D[2024-04-18],
      kennel_number: "21",
      last_updated: ~D[2025-05-04],
      name: "Elton (new name)",
      pit_number: nil,
      sex: :male_neutered,
      source: :holding_stray,
      status: "adoption assessment"
    }
  end

  defp pet2_updated do
    %VancouverImpoundWatch.Pet{
      aco: "40",
      age_category: :adult,
      id: 35_322,
      approx_weight: nil,
      breed: "miniature poodle",
      code: nil,
      color: "Brown",
      date_impounded: ~D[2025-04-16],
      disposition_date: ~D[2024-04-18],
      kennel_number: "21",
      last_updated: ~D[2025-05-04],
      name: "Elton (new name)",
      pit_number: nil,
      sex: :male_neutered,
      source: :holding_stray,
      status: "ride home free"
    }
  end
end
