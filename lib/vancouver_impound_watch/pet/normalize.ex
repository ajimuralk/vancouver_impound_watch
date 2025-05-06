defmodule VancouverImpoundWatch.Pet.Normalize do
  @moduledoc """
  Functions for transforming raw data from the API into a Pet struct 
  """

  alias VancouverImpoundWatch.Pet

  @spec from_map(map()) :: {:ok, Pet.t()} | {:error, any()}
  def from_map(raw) do
    with {:ok, id} <- parse_id(raw["animalid"]),
         {:ok, breed} <- convert_required_string(raw["breed"]),
         {:ok, date_impounded} <- parse_required_date(raw["dateimpounded"]),
         {:ok, source} <- convert_source(raw["source"]),
         {:ok, status} <- convert_required_string(raw["status"]) do
      {:ok,
       %Pet{
         aco: convert_string(raw["aco"]),
         age_category: convert_age(raw["age_category"]),
         id: id,
         approx_weight: convert_string_int(raw["approxweight"]),
         breed: breed,
         code: convert_code(raw["code"]),
         color: convert_string(raw["color"]),
         date_impounded: date_impounded,
         disposition_date: parse_date(raw["dispositiondate"]),
         last_updated: Date.utc_today(),
         name: convert_string(raw["name"]),
         pit_number: convert_string(raw["pitnumber"]),
         kennel_number: convert_string(raw["kennelnumber"]),
         sex: convert_sex(raw["sex"]),
         source: source,
         status: status
       }}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp convert_age(age) when is_binary(age) do
    case String.downcase(age) do
      "adult" -> :adult
      "senior" -> :senior
      "puppy" -> :puppy
      "young adult" -> :young_adult
      _ -> nil
    end
  end

  defp convert_age(_), do: nil

  defp convert_code(code) when is_binary(code) do
    case String.downcase(code) do
      "green" -> :green
      "yellow" -> :yellow
      "blue" -> :blue
      _ -> nil
    end
  end

  defp convert_code(_), do: nil

  defp convert_sex("M"), do: :male
  defp convert_sex("F"), do: :female
  defp convert_sex("M/N"), do: :male_neutered
  defp convert_sex("F/S"), do: :female_spayed
  defp convert_sex(_), do: :unknown

  defp convert_string(s) when is_binary(s), do: s
  defp convert_string(_), do: nil

  defp convert_string_int(s) when is_binary(s) do
    {int, _} = Integer.parse(s)
    int
  end

  defp convert_string_int(s) when is_number(s), do: s
  defp convert_string_int(_), do: nil

  defp convert_required_string(s) when is_binary(s), do: {:ok, String.downcase(s)}
  defp convert_required_string(_), do: {:error, :missing_or_invalid_string}

  defp convert_source(source) when is_binary(source) do
    source =
      case String.downcase(source) do
        "brought-in" -> :brought_in
        "holding stray" -> :holding_stray
        "seized" -> :seized
        "vpd impound" -> :vpd_impound
        _ -> nil
      end

    {:ok, source}
  end

  defp convert_source(_), do: {:error, :missing_source}

  defp parse_date(nil), do: nil

  defp parse_date(date) when is_binary(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp parse_required_date(nil), do: {:error, :missing_date}

  defp parse_required_date(date) when is_binary(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> {:ok, date}
      _ -> {:error, :invalid_date}
    end
  end

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> {:ok, int}
      _ -> {:error, :missing_or_invalid_id}
    end
  end

  defp parse_id(_), do: {:error, :missing_or_invalid_id}
end
