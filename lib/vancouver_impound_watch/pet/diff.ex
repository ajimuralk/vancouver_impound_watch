defmodule VancouverImpoundWatch.Pet.Diff do
  @moduledoc """
    Logic for comparing two %Pet{} structs and determining update status for actionable updates.
  """

  alias VancouverImpoundWatch.Pet

  @type diff_status :: :new | :unchanged | :updated

  @actionable_changes [:status, :disposition_date]

  @spec compare(Pet.t() | nil, Pet.t()) :: diff_status
  def compare(nil, _new), do: :new

  @spec compare(Pet.t(), Pet.t()) :: diff_status
  def compare(existing, new) do
    if compare_fields(existing, new) do
      :unchanged
    else
      :updated
    end
  end

  defp compare_fields(existing, new) do
    Map.take(existing, @actionable_changes) ==
      Map.take(new, @actionable_changes)
  end
end
