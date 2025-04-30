defmodule VancouverImpoundWatch.FetcherTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias VancouverImpoundWatch.Fetcher

  doctest VancouverImpoundWatch.Fetcher

  describe "get/0" do
    setup do
      Req.Test.stub(Fetcher, fn conn ->
        Req.Test.json(conn, raw_valid_results())
      end)
    end

    test "it fetches and returns valid results" do
      {:ok, results} = Fetcher.get()
      assert 3 == Enum.count(results)
    end

    test "it returns valid results and logs warnings when handling malformed results" do
      Req.Test.stub(Fetcher, fn conn ->
        Req.Test.json(conn, raw_mixed_results())
      end)

      {{:ok, result}, log} = with_log(fn -> Fetcher.get() end)

      assert 3 == Enum.count(result)

      assert log =~
               ~s([warning] Invalid records not processed: [:missing_or_invalid_id, :missing_date])
    end
  end

  defp raw_mixed_results do
    %{
      "results" => [
        %{
          "aco" => "40",
          "age_category" => "Adult",
          "animalid" => "35322",
          "approxweight" => nil,
          "breed" => "Miniature Poodle",
          "code" => nil,
          "color" => "Brown",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => nil,
          "kennelnumber" => "21",
          "name" => "Elton (new name)",
          "pitnumber" => nil,
          "receiptnumber" => nil,
          "sex" => "M/N",
          "source" => "HOLDING STRAY",
          "status" => "Adoption Assessment"
        },
        %{
          "aco" => "43",
          "age_category" => "Adult",
          "animalid" => "35320",
          "approxweight" => nil,
          "breed" => "Yorkie X",
          "code" => nil,
          "color" => "Grey & tan",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => "2025-04-16",
          "kennelnumber" => "200",
          "name" => "Chloe",
          "pitnumber" => nil,
          "receiptnumber" => "DI 25-214924 JA",
          "sex" => "F",
          "source" => "HOLDING STRAY",
          "status" => "Redeemed"
        },
        %{
          "aco" => nil,
          "age_category" => "Adult",
          "animalid" => "35321",
          "approxweight" => nil,
          "breed" => "Miniature Poodle X",
          "code" => nil,
          "color" => "White",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => "2025-04-17",
          "kennelnumber" => "200",
          "name" => "Kookie",
          "pitnumber" => nil,
          "receiptnumber" => "DI 25-215213 - JA",
          "sex" => "F",
          "source" => "BROUGHT-IN",
          "status" => "Redeemed"
        },
        %{
          "aco" => nil,
          "age_category" => "Adult",
          "animalid" => "20951",
          "approxweight" => nil,
          "breed" => "Rat",
          "code" => nil,
          "color" => "White",
          "dateimpounded" => nil,
          "dispositiondate" => "2025-04-17",
          "kennelnumber" => "200",
          "name" => nil,
          "pitnumber" => nil,
          "receiptnumber" => nil,
          "sex" => "X",
          "source" => "BROUGHT-IN",
          "status" => nil
        },
        %{
          "aco" => nil,
          "age_category" => nil,
          "animalid" => "invalid-id",
          "approxweight" => nil,
          "breed" => "Dove",
          "code" => nil,
          "color" => "Gray",
          "dateimpounded" => nil,
          "dispositiondate" => "2025-04-17",
          "kennelnumber" => nil,
          "name" => nil,
          "pitnumber" => nil,
          "receiptnumber" => nil,
          "sex" => "X",
          "source" => "BROUGHT-IN",
          "status" => "Confused"
        }
      ],
      "total_count" => 5
    }
  end

  defp raw_valid_results do
    %{
      "results" => [
        %{
          "aco" => "40",
          "age_category" => "Adult",
          "animalid" => "35322",
          "approxweight" => nil,
          "breed" => "Miniature Poodle",
          "code" => nil,
          "color" => "Brown",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => nil,
          "kennelnumber" => "21",
          "name" => "Elton (new name)",
          "pitnumber" => nil,
          "receiptnumber" => nil,
          "sex" => "M/N",
          "source" => "HOLDING STRAY",
          "status" => "Adoption Assessment"
        },
        %{
          "aco" => "43",
          "age_category" => "Adult",
          "animalid" => "35320",
          "approxweight" => nil,
          "breed" => "Yorkie X",
          "code" => nil,
          "color" => "Grey & tan",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => "2025-04-16",
          "kennelnumber" => "200",
          "name" => "Chloe",
          "pitnumber" => nil,
          "receiptnumber" => "DI 25-214924 JA",
          "sex" => "F",
          "source" => "HOLDING STRAY",
          "status" => "Redeemed"
        },
        %{
          "aco" => nil,
          "age_category" => "Adult",
          "animalid" => "35321",
          "approxweight" => nil,
          "breed" => "Miniature Poodle X",
          "code" => nil,
          "color" => "White",
          "dateimpounded" => "2025-04-16",
          "dispositiondate" => "2025-04-17",
          "kennelnumber" => "200",
          "name" => "Kookie",
          "pitnumber" => nil,
          "receiptnumber" => "DI 25-215213 - JA",
          "sex" => "F",
          "source" => "BROUGHT-IN",
          "status" => "Redeemed"
        }
      ],
      "total_count" => 3
    }
  end
end
