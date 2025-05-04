defmodule VancouverImpoundWatch.Pet.NormalizeTest do
  @moduledoc """
  Tests for transforming raw data from the API into a Pet struct 
  """

  use ExUnit.Case, async: true

  alias VancouverImpoundWatch.Pet
  alias VancouverImpoundWatch.Pet.Normalize

  describe "from_map/1" do
    test "it returns a Pet struct with expected map data" do
      raw_map = %{
        "aco" => "44",
        "age_category" => "Young Adult",
        "animalid" => "35319",
        "approxweight" => "9.8",
        "breed" => "Korean Village Dog",
        "code" => "green",
        "color" => "White",
        "dateimpounded" => "2025-04-14",
        "dispositiondate" => "2025-04-14",
        "kennelnumber" => "200",
        "name" => "Levi",
        "pitnumber" => "1",
        "receiptnumber" => "123",
        "sex" => "M/N",
        "source" => "HOLDING STRAY",
        "status" => "Owners contacted and on their way"
      }

      assert {:ok,
              %Pet{
                aco: "44",
                age_category: :young_adult,
                id: 35_319,
                approx_weight: 9,
                breed: "korean village dog",
                code: :green,
                color: "White",
                date_impounded: Date.new!(2025, 4, 14),
                disposition_date: Date.new!(2025, 4, 14),
                kennel_number: "200",
                last_updated: Date.utc_today(),
                name: "Levi",
                pit_number: "1",
                sex: :male_neutered,
                source: :holding_stray,
                status: "owners contacted and on their way"
              }} == Normalize.from_map(raw_map)
    end

    test "it returns an error when required values are nil" do
      raw_map = %{
        "aco" => nil,
        "age_category" => nil,
        "animalid" => nil,
        "approxweight" => nil,
        "breed" => "Pig",
        "code" => nil,
        "color" => "Pink",
        "dateimpounded" => "2025-04-15",
        "dispositiondate" => nil,
        "kennelnumber" => "200",
        "name" => nil,
        "pitnumber" => "1",
        "receiptnumber" => nil,
        "sex" => nil,
        "source" => "HOLDING STRAY",
        "status" => "Processing"
      }

      assert {:error, :missing_or_invalid_id} ==
               Normalize.from_map(raw_map)
    end
  end
end
