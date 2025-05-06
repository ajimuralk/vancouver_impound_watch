defmodule VancouverImpoundWatch.Pet.PolicyTest do
  @moduledoc """
  Tests for registered pet retention policies
  """

  use ExUnit.Case, async: true

  alias VancouverImpoundWatch.Pet.Policy

  describe "pets_to_evict/1" do
    test "it returns ids for expired pets" do
      # set date to 7 days in the past
      {expired_id, _} = expired_pet = pet(1, "reported", Date.add(Date.utc_today(), -7))
      {valid_id, _} = valid_pet = pet(2, "reported", Date.utc_today())

      expired_ids = Policy.pets_to_evict([valid_pet, expired_pet])
      assert expired_id in expired_ids
      refute valid_id in expired_ids
    end

    test "it returns ids for pets with terminal statuses" do
      today = Date.utc_today()

      {terminal_id_1, _} = terminal_pet_1 = pet(1, "redeemed", today)
      {terminal_id_2, _} = terminal_pet_2 = pet(2, "ride home free", today)
      {terminal_id_3, _} = terminal_pet_3 = pet(3, "deceased", today)
      {terminal_id_4, _} = terminal_pet_4 = pet(4, "released", today)
      {terminal_id_5, _} = terminal_pet_5 = pet(5, "sold", today)
      {valid_id, _} = valid_pet = pet(6, "reported", today)

      terminal_ids =
        Policy.pets_to_evict([
          terminal_pet_1,
          terminal_pet_2,
          terminal_pet_3,
          terminal_pet_4,
          terminal_pet_5,
          valid_pet
        ])

      for id <- [terminal_id_1, terminal_id_2, terminal_id_3, terminal_id_4, terminal_id_5] do
        assert id in terminal_ids
      end

      refute valid_id in terminal_ids
    end
  end

  defp pet(id, status, last_updated) do
    {id,
     %VancouverImpoundWatch.Pet{
       aco: "40",
       age_category: :adult,
       id: id,
       approx_weight: nil,
       breed: "miniature poodle",
       code: nil,
       color: "Brown",
       date_impounded: ~D[2025-04-16],
       disposition_date: ~D[2024-04-18],
       kennel_number: "21",
       last_updated: last_updated,
       name: "Elton (new name)",
       pit_number: nil,
       sex: :male_neutered,
       source: :holding_stray,
       status: status
     }}
  end
end
