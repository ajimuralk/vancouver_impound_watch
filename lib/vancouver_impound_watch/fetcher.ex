defmodule VancouverImpoundWatch.Fetcher do
  @moduledoc """
  A module that makes requests to the Vancouver OpenData catalog for animal control inventory
  """

  require Logger

  alias VancouverImpoundWatch.Pet
  alias VancouverImpoundWatch.Pet.Normalize

  @typep http_status :: integer()

  @spec get() ::
          {:ok, [Pet.t()]}
          | {:error, {:unexpected_response, http_status()}}
          | {:error, String.t()}
  def get do
    [url: url(), method: :get, headers: [{"accept", "application/json"}]]
    |> Keyword.merge(Application.get_env(:vancouver_impound_watch, :req_options, []))
    |> Req.request()
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: %{"results" => records}}}) do
    {valid, error_msgs} =
      Enum.reduce(records, {[], []}, fn record, {valid, error_msgs} ->
        case Normalize.from_map(record) do
          {:ok, pet} ->
            {[pet | valid], error_msgs}

          {:error, error} ->
            {valid, [error | error_msgs]}
        end
      end)

    if error_msgs != [],
      do: Logger.warning("Invalid records not processed: #{inspect(error_msgs)}")

    {:ok, valid}
  end

  # TODO: write tests for error responses
  defp handle_response({:ok, %Req.Response{} = res}) do
    Logger.error("#{inspect(res.status)} ERROR: Unable to process records")
    {:error, {:unexpected_response, res.status}}
  end

  defp handle_response({:error, error}) do
    Logger.error("ERROR: Unable to process records")
    {:error, error}
  end

  @doc """
  Extracts the `[year, month, day]` from a `DateTime` struct.

  ### Example

      iex> dt = DateTime.from_naive!(~N[2025-04-15 09:23:00], "America/Vancouver")
      iex> VancouverImpoundWatch.Fetcher.format_date(dt)
      ["2025", "04", "15"]
  """
  @spec format_date(DateTime.t()) :: list(String.t())
  def format_date(dt) do
    dt
    |> DateTime.to_iso8601()
    |> String.split("T")
    |> hd()
    |> String.split("-")
  end

  defp url do
    [year, month, day] = format_date(DateTime.now!("America/Vancouver"))

    """
    https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/animal-control-inventory-register/\
    records?limit=100&refine=dateimpounded%3A%22#{year}%2F#{month}%2F#{day}%22\
    """
  end
end
