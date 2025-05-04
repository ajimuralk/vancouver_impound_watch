defmodule VancouverImpoundWatch.Scheduler do
  @moduledoc """
  A GenServer responsible for scheduling calls to fetch from the API.
  """
  use GenServer

  alias VancouverImpoundWatch.Fetcher
  alias VancouverImpoundWatch.Pet
  alias VancouverImpoundWatch.Pet.Diff
  alias VancouverImpoundWatch.RegisteredPetTable

  @holding_period_in_days 6
  @one_hour_in_secs 3600
  @one_day_in_secs 3600 * 24
  @terminal_statuses ["redeemed", "deceased", "released", "sold", "ride home free"]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    cleanup_ref = Process.send_after(self(), :cleanup_cache, @one_day_in_secs)
    fetch_interval_secs = Keyword.get(opts, :fetch_interval_secs, @one_hour_in_secs)

    fetch_ref =
      Process.send_after(
        self(),
        :fetch,
        fetch_interval_secs
      )

    mod = Keyword.get(opts, :fetcher, Fetcher)

    {:ok,
     %{
       cleanup_cache_timer: cleanup_ref,
       fetcher: mod,
       fetch_interval_secs: fetch_interval_secs,
       fetch_timer: fetch_ref
     }}
  end

  @impl true
  def handle_info(:cleanup_cache, state) do
    RegisteredPetTable.all()
    |> pets_to_evict()
    |> Enum.each(&RegisteredPetTable.evict/1)

    cleanup_ref = Process.send_after(self(), :cleanup_cache, @one_day_in_secs)
    {:noreply, %{state | cleanup_cache_timer: cleanup_ref}}
  end

  @impl true
  def handle_info(:fetch, %{fetcher: mod} = state) do
    case mod.get() do
      {:ok, records} ->
        handle_records(records)

      # TODO: Handle HTTP errors that req doesn't catch
      {:error, {:unexpected_response, error}} ->
        error

      {:error, error} ->
        error
    end

    fetch_ref = Process.send_after(self(), :fetch, state.fetch_interval_secs)

    {:noreply, %{state | fetch_timer: fetch_ref}}
  end

  @spec pets_to_evict(Pet.t()) :: [integer()]
  def pets_to_evict(records) do
    Enum.flat_map(
      records,
      fn {_id, r} ->
        if expired?(r.last_updated) or terminal_status?(r.status) do
          [r.id]
        else
          []
        end
      end
    )
  end

  defp expired?(date) do
    Date.diff(Date.utc_today(), date) > @holding_period_in_days
  end

  defp terminal_status?(status) do
    status in @terminal_statuses
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
