defmodule VancouverImpoundWatch.Pet.Policy do
  @moduledoc """
  Functions for determining registered pet retention business logic.
  """
  alias VancouverImpoundWatch.Pet

  @holding_period_in_days 5
  @terminal_statuses ["redeemed", "deceased", "released", "sold", "ride home free"]

  @spec pets_to_evict([{integer(), Pet.t()}]) :: [integer()]
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
end
