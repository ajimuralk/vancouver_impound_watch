defmodule VancouverImpoundWatch.Pet do
  @moduledoc """
  Represents normalized pet data.
  """

  @enforce_keys [:id, :breed, :date_impounded, :sex, :source, :status]
  defstruct [
    :aco,
    :age_category,
    :id,
    :approx_weight,
    :breed,
    :code,
    :color,
    :date_impounded,
    :disposition_date,
    :kennel_number,
    :last_updated,
    :name,
    :pit_number,
    :sex,
    :source,
    :status
  ]

  @type age_category :: :adult | :senior | :puppy | :young_adult
  @type code :: :green | :yellow | :blue
  @type sex :: :male | :female | :male_neutered | :female_spayed | :unknown
  @type source :: :brought_in | :holding_stray | :seized | :vpd_impound

  @type t :: %__MODULE__{
          aco: String.t() | nil,
          age_category: age_category() | nil,
          id: integer(),
          approx_weight: integer() | nil,
          breed: String.t(),
          code: code() | nil,
          color: String.t() | nil,
          date_impounded: Date.t(),
          disposition_date: Date.t() | nil,
          last_updated: Date.t(),
          kennel_number: integer() | nil,
          name: String.t() | nil,
          pit_number: integer() | nil,
          sex: sex(),
          source: source(),
          status: String.t()
        }
end
