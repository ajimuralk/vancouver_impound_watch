defmodule VancouverImpoundWatch.Scheduler do
  @moduledoc """
  A GenServer responsible for scheduling calls to fetch from the API.
  """
  use GenServer

  alias VancouverImpoundWatch.Fetcher
  alias VancouverImpoundWatch.Pet.Diff
  alias VancouverImpoundWatch.Pet.Policy
  alias VancouverImpoundWatch.RegisteredPetTable

  require Logger

  @cleanup_interval 3600 * 24 * 1000
  @one_hour_in_secs 3600

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    mod = Keyword.get(opts, :fetcher, Fetcher)
    fetch_interval = Keyword.get(opts, :fetch_interval_secs, @one_hour_in_secs) * 1000

    cleanup_ref = Process.send_after(self(), :cleanup_cache, @cleanup_interval)

    fetch_ref =
      Process.send(self(), :fetch, [])

    {:ok,
     %{
       cleanup_cache_timer: cleanup_ref,
       fetcher: mod,
       fetch_interval: fetch_interval,
       fetch_timer: fetch_ref
     }}
  end

  @impl true
  def handle_info(:cleanup_cache, state) do
    RegisteredPetTable.all()
    |> Policy.pets_to_evict()
    |> Enum.each(&RegisteredPetTable.evict/1)

    cleanup_ref = Process.send_after(self(), :cleanup_cache, @cleanup_interval)
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

    fetch_ref = Process.send_after(self(), :fetch, state.fetch_interval)

    {:noreply, %{state | fetch_timer: fetch_ref}}
  end

  defp handle_records(records) do
    Enum.each(records, fn incoming_pet ->
      case RegisteredPetTable.lookup(incoming_pet) |> Diff.compare(incoming_pet) do
        :new ->
          # TODO: publish
          RegisteredPetTable.insert(incoming_pet)
          Logger.info("New pet registered: #{inspect(incoming_pet)}")

        :updated ->
          # TODO: check status, publish update
          RegisteredPetTable.insert(incoming_pet)
          Logger.info("Registered pet updated: #{inspect(incoming_pet)}")

        :unchanged ->
          :ok
      end
    end)
  end
end
