defmodule VancouverImpoundWatch.Scheduler do
  @moduledoc """
  A GenServer responsible for scheduling calls to fetch from the API.
  """
  use GenServer

  alias VancouverImpoundWatch.Fetcher
  alias VancouverImpoundWatch.Pet.Diff
  alias VancouverImpoundWatch.RegisteredPetTable

  @one_hour_in_secs 3600

  @impl true
  def init(opts) do
    interval_secs =
      Process.send_after(
        self(),
        Keyword.get(opts, :fetch_interval_secs, @one_hour_in_secs),
        :fetch
      )

    {:ok, %{fetch_interval_timer: interval_secs}}
  end

  @impl true
  def handle_info(:fetch, state) do
    case Fetcher.get() do
      {:ok, records} ->
        handle_records(records)

      # TODO: Handle HTTP errors that req doesn't catch
      {:error, {:unexpected_response, error}} ->
        error

      {:error, error} ->
        error
    end

    interval_secs = Process.send_after(self(), state.fetch_interval_secs, :fetch)

    {:noreply, %{fetch_interval_timer: interval_secs}}
  end

  defp handle_records(records) do
    Enum.each(records, fn incoming_pet ->
      case RegisteredPetTable.lookup(incoming_pet) |> Diff.compare(incoming_pet) do
        :new ->
          # TODO: publish
          RegisteredPetTable.insert(incoming_pet)

        :updated ->
          # TODO: check status, publish update, purge from cache on certain updates
          RegisteredPetTable.insert(incoming_pet)

        :unchanged ->
          :ok
      end
    end)
  end
end
